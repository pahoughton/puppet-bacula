# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::dir (
  $db_backend = 'postgresql',
  $db_host    = 'localhost',
  $db_user    = 'bacula',
  $db_pass    = 'bacula',
  $db_name    = 'bacula',
  $max_jobs   = 5,
  $mail_to    = 'root@localhost',
  $service    = 'bacula-dir',
  $workdir    = '/var/lib/bacula/work',
  $sd_host    = undef,
  ) {
  
  if $db_host == 'localhost' or $db_host == "${::hostname}" {
    class { 'bacula::database' :
      backend => $db_backend,
      name  => $db_name,
      user  => $db_user,
      pass  => $db_pass,
    }
  }
  
  if $::operatingsystem == 'Fedora' {
    $package = 'bacula-director'
  } else {
    $package = "bacula-director-${db_backend}"
  }
  package { $package :
    ensure => 'installed',
  }
  file { ['/etc/bacula/scripts',
          '/var/run/bacula',
          '/var/lib/bacula',
          $workdir,] :
    ensure  => 'directory',
    owner   => 'bacula',
    group   => 'bacula',
  }
    
  file { '/etc/bacula/bacula-dir.conf' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => template('bacula/bacula-dir.conf.erb'),
    notify  => Service[$service],
    require => Package[$package],
  }
  
  file { '/etc/bacula/bacula-dir.d' :
    ensure  => 'directory',
    owner   => 'bacula',
    group   => 'bacula',
    before  => Service[$service],
    require => Package[$package],
  }
  file { '/etc/bacula/bacula-dir.d/empty.conf' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => "# empty\n",
    before  => Service[$service],
  }

  # Postgres Backup Scripts
  file { '/etc/bacula/scripts/pgdump.bash' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => template('bacula/pgdump.bash.erb'),
  }
  file { '/etc/bacula/scripts/pgclean.bash' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => template('bacula/pgclean.bash.erb'),
  }
  file { '/etc/bacula/scripts/pglist.bash' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => template('bacula/pglist.bash.erb'),
  }

  service { $service :
    ensure => 'running',
    enable => true,
  }
  class { 'bacula::fd' :
    dir_host => $::hostname,
  }
  class { 'bacula::bconsole' : }
    
  bacula::dir::client { $::hostname : }

  if $sd_host {
    bacula::dir::storage { 'Default' :
      sd_host  => "${sd_host}",
      device   => 'File',
    }
  }
  bacula::job { 'Default' :
    jtype           => 'JobDefs',
    client          => "${::hostname}-fd",
    type            => 'Backup',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    priority        => 10,
    write_bootstrap => '/var/spool/bacula/%c.bsr',
  }
  bacula::pool { 'Default' :
    recycle    => 'yes',
    auto_prune => 'yes',
    vol_retent => '30 days',
  }
  bacula::fileset { 'PostgresDefault' :
    include => [ [ ['/var/lib/pgsql/backups/globalobjects.dump',
                    '|/etc/bacula/scripts/pglist.bash',
                    ],
                   ['compression = GZIP9',
                    'signature = MD5',
                    'readfifo = yes']
                   ],
               ],
  }

  case $db_backend {
    'postgresql' : {
      bacula::jobdefs::postgresql { "Postgres-${::hostname}" :
        client => "${::hostname}-fd",
      }
    }
    default : {
      fail( "unsupport db backend: ${db_backend}" )
    }
  }
}
