# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# No spaces in subcomponent names.
class bacula::dir (
  $configdir        = '/etc/bacula',
  $rundir           = '/var/run/bacula',
  $libdir           = '/var/lib/bacula',
  $homedir          = '/srv/bacula',
  $workdir          = '/srv/bacula/work',
  $backupdir        = '/srv/bacula/backups',
  $restoredir       = '/srv/bacula/restore',
  $db_backend       = 'postgresql',
  $db_host          = 'localhost',
  $db_user          = 'bacula',
  $db_pass          = 'bacula',
  $db_name          = 'bacula',
  $pg_dumpdir       = '/srv/postgres/dump', # Fixme
  $max_jobs         = 5,
  $mail_to          = 'root@localhost',
  $sd_host          = undef,
  $user             = 'bacula',
  $group            = 'bacula',
  $postgresql_user  = 'postgres',
  $postgresql_group = 'postgres',
  ) {

  package { $package :
    ensure => 'installed',
  }

  case $::operatingsystem {
    'Fedora' : {
      $package    = 'bacula-director'
      $service    = 'bacula-dir'
    }
    'CentOS' : {
      $package    = "bacula-director-${db_backend}"
      $service    = 'bacula-dir'
    }
    'Ubuntu' : {
      case $db_backend {
        'postgresql' : {
          $package    = ['bacula-common-pgsql','bacula-director-pgsql']
        }
        default : {
          fail("Ubuntu unsupported db_backend ${db_backend}")
        }
      }
      $service    = 'bacula-director'
    }
  }

  File {
    owner   => $user,
    group   => $group,
    notify  => Service[$service],
    require => Package[$package],
  }


  if $db_host == 'localhost' or $db_host == $::hostname {
    class { 'bacula::dir::database' :
      backend => $db_backend,
      name    => $db_name,
      user    => $db_user,
      pass    => $db_pass,
    }
  }

  file { ["${configdir}/scripts",
          $rundir,
          $libdir,
          $workdir,
          $restoredir,] :
    ensure  => 'directory',
    mode    => '0750',
  }

  file { "${configdir}/bacula-dir.conf" :
    ensure  => 'file',
    content => template('bacula/bacula-dir.conf.erb'),
  }

  file { "${configdir}/bacula-dir.d" :
    ensure  => 'directory',
  }
  file { "${configdir}/bacula-dir.d/empty.conf" :
    ensure  => 'file',
    content => "# empty\n",
  }

  # Postgres Backup Support
  file { [$pg_dumpdir, "${pg_dumpdir}/fifo"] :
    ensure  => 'directory',
    owner   => $postgresql_user,
    group   => $postgresql_group,
    mode    => '0775',
  }
  # fixme - these belong on any pg backup
  file { "${libdir}/scripts/pgdump.bash" :
    ensure  => 'file',
    mode    => '0555',
    content => template('bacula/pgdump.bash.erb'),
    require => Package[$package],
  }
  file { "${libdir}/scripts/pgclean.bash" :
    ensure  => 'file',
    mode    => '0555',
    content => template('bacula/pgclean.bash.erb'),
    require => Package[$package],
  }
  file { "${libdir}/scripts/pglist.bash" :
    ensure  => 'file',
    mode    => '0555',
    content => template('bacula/pglist.bash.erb'),
    require => Package[$package],
  }

  service { $service :
    ensure => 'running',
    enable => true,
  }
  class { 'bacula::fd' :
    dir_host => $::hostname,
  }
  bacula::dir::client { $::hostname : }
  class { 'bacula::bconsole' : }

  if $sd_host {
    bacula::dir::storage { 'Default' :
      sd_host    => $sd_host,
      device     => 'Default',
      media_type => 'File'
    }
  }
  bacula::dir::job { 'Resore' :
    jtype           => 'Job',
    client          => $::hostname,
    type            => 'Restore',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    fileset         => 'FullSet',
    where           => $restoredir,
  }
  bacula::dir::job { 'Default' :
    jtype           => 'JobDefs',
    client          => $::hostname,
    type            => 'Backup',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    priority        => 10,
    write_bootstrap => "${workdir}/%c.bsr",
  }
  bacula::dir::pool { 'Default' :
    recycle       => 'yes',
    auto_prune    => 'yes',
    vol_retent    => '30 days',
    max_vol_bytes => '100G',
    label_format  => "${::hostname}.backup.vol.",
  }
  bacula::dir::fileset { 'FullSet' :
    include => [ [ ['/','/home'],['signature = MD5'] ] ],
  }
  bacula::dir::fileset { 'PostgresDefault' :
    include => [  [ [ '/var/lib/pgsql/backups/globalobjects.dump',
                      "|${libdir}/scripts/pglist.bash",
                      ],
                    [ 'signature = MD5',
                      'readfifo = yes'
                      ],
                    ],
                  ],
  }
  sudo::conf { 'bacula-postgres' :
    priority => 10,
    content  => 'bacula ALL = (postgres) NOPASSWD: ALL',
  }
  case $db_backend {
    'postgresql' : {
      bacula::jobdefs::postgresql { "Postgres-${::hostname}" :
        client => $::hostname,
      }
    }
    default : {
      fail( "unsupport db backend: ${db_backend}" )
    }
  }
}
