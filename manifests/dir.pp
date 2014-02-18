# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# No spaces in subcomponent names.
class bacula::dir (
  $db_backend       = 'postgresql',
  $db_host          = 'localhost',
  $db_user          = 'bacula',
  $db_pass          = 'bacula',
  $db_name          = 'bacula',
  $max_jobs         = 5,
  $mail_to          = 'root@localhost',
  $workdir          = '/var/lib/bacula/work',
  $sd_host          = undef,
  $user             = 'bacula',
  $group            = 'bacula',
#  $pg_dumpdir       = undef,
  $postgresql_user  = 'postgres',
  $postgresql_group = 'postgres',
  ) {
  
  case $::operatingsystem {
    'Fedora' : {
      $package    = 'bacula-director'
      $pg_dumpdir = '/var/lib/pgsql/backups'
      $service    = 'bacula-dir'
    }
    'CentOS' : {
      $package    = "bacula-director-${db_backend}"
      $pg_dumpdir = '/var/lib/pgsql/backups'
      $service    = 'bacula-dir'
    }
    'Ubuntu' : {
      case $db_backend {
        'postgresql' : {
          $package    = ['bacula-common-pgsql','bacula-director-pgsql']
        }
        default : {
          fail("Ubuntu unsupported db_backend $db_backend")
        }
      }
      $pg_dumpdir = '/var/lib/postgresql/backups'
      $service    = 'bacula-director'
    }
  }
  
  if $db_host == 'localhost' or $db_host == "${::hostname}" {
    class { 'bacula::database' :
      backend => $db_backend,
      name  => $db_name,
      user  => $db_user,
      pass  => $db_pass,
    }
  }

  package { $package :
    ensure => 'installed',
  }
  file { ['/etc/bacula/scripts',
          '/var/run/bacula',
          '/var/lib/bacula',
          $workdir,] :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
  }
    
  file { '/etc/bacula/bacula-dir.conf' :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    content => template('bacula/bacula-dir.conf.erb'),
    notify  => Service[$service],
    require => Package[$package],
  }
  
  file { '/etc/bacula/bacula-dir.d' :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    before  => Service[$service],
    require => Package[$package],
  }
  file { '/etc/bacula/bacula-dir.d/empty.conf' :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    content => "# empty\n",
    before  => Service[$service],
  }

  # Postgres Backup Support
  file { [$pg_dumpdir, "${pg_dumpdir}/fifo"] :
    ensure  => 'directory',
    owner   => $postgresql_user,
    group   => $postgresql_group,
    mode    => '0775',
  }
  file { '/etc/bacula/scripts/pgdump.bash' :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0555',
    content => template('bacula/pgdump.bash.erb'),
  }
  file { '/etc/bacula/scripts/pgclean.bash' :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0555',
    content => template('bacula/pgclean.bash.erb'),
  }
  file { '/etc/bacula/scripts/pglist.bash' :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0555',
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
      sd_host    => "${sd_host}",
      device     => 'Default',
      media_type => 'File'
    }
  }
  bacula::job { 'Resore' :
    jtype           => 'Job',
    client          => "${::hostname}-fd",
    type            => 'Restore',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    fileset         => 'FullSet',
    where           => '/tmp/bacula-restores',
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
    recycle       => 'yes',
    auto_prune    => 'yes',
    vol_retent    => '30 days',
    max_vol_bytes => '100G',
  }
  bacula::fileset { 'FullSet' :
    include => [ [ ['/','/home'],['signature = MD5'] ] ],
  }
  bacula::fileset { 'PostgresDefault' :
    include => [ [ ['/var/lib/pgsql/backups/globalobjects.dump',
                    "|su -c '/etc/bacula/scripts/pglist.bash' - postgres",
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
