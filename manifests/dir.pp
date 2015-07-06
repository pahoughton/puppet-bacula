# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# No spaces in subcomponent names.
class bacula::dir (
  $dirname      = $::bacula::params::dirname,
  $configdir    = $::bacula::params::configdir,
  $rundir       = $::bacula::params::rundir,
  $libdir       = $::bacula::params::libdir,
  $workdir      = $::bacula::params::workdir,
  $restoredir   = $::bacula::params::restoredir,
  $db_backend   = 'postgresql',
  $db_host      = 'localhost',
  $db_adm_pass  = undef,
  $db_user      = 'bacula',
  $db_pass      = 'bacula',
  $db_name      = 'bacula',
  $db_dumpdir   = "$::bacula::params::workdir/dump", # Fixme
  $max_jobs     = 5,
  $mail_to      = 'root@localhost',
  $sd_addr      = undef,
  $user         = $::bacula::params::user,
  $group        = $::bacula::params::group,
#  $db_nix_user  = 'postgres',
#  $db_nix_group = 'postgres',
  ) inherits ::bacula::params {

  case $::operatingsystem {
    'Fedora' : {
      $packages   = ['bacula-director']
      $service    = 'bacula-dir'
    }
    'CentOS','RedHat' : {
      $packages   = ["bacula-director-${db_backend}"]
      $service    = 'bacula-dir'
    }
    'Ubuntu' : {
      case $db_backend {
        'postgresql' : {
          $packages   = ['bacula-common-pgsql','bacula-director-pgsql']
        }
        default : {
          fail("Ubuntu unsupported db_backend ${db_backend}")
        }
      }
      $service    = 'bacula-director'
    }
    default : {
      fail("unsupported operatingsystem '$::operatingsystem'")
    }
  }

  package { $packages :
    ensure => 'installed',
  }

  File {
    owner   => $user,
    group   => $group,
    notify  => Service[$service],
    require => Package[$package],
  }

  class { 'bacula::dir::database' :
    adm_pass => $db_adm_pass,
    backend  => $db_backend,
    host     => $db_host,
    name     => $db_name,
    user     => $db_user,
    pass     => $db_pass,
  }

  file { [$configdir,
          $rundir,
          $libdir,
          "${libdir}/scripts",
          $workdir,
          $restoredir,] :
    ensure  => 'directory',
    mode    => '0750',
  }

  file { "${configdir}/bacula-dir.conf" :
    ensure  => 'file',
    content => template('bacula/bacula-dir.conf.erb'),
  }

  file { "${configdir}/dir.d" :
    ensure  => 'directory',
  }
  file { "${configdir}/dir.d/empty.conf" :
    ensure  => 'file',
    content => "# empty\n",
  }

  service { $service :
    ensure => 'running',
    enable => true,
  }
  class { 'bacula::fd' :
    dirname       => "${::hostname}-dir",
    pgres_support => true,
    fd_only       => false,
  }
  bacula::dir::client { $::hostname :
    configdir => $configdir,
  }
  class { 'bacula::bconsole' : }

  if $sd_addr {
    bacula::dir::storage { 'Default' :
      sd_host    => $sd_addr,
      device     => 'Default',
      media_type => 'File'
    }
  }
  bacula::dir::job { 'Restore' :
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
  # sudo::conf { 'bacula-postgres' :
  #   priority => 10,
  #   content  => 'bacula ALL = (postgres) NOPASSWD: ALL',
  # }
  case $db_backend {
    'postgresql' : {
      bacula::dir::jobdefs::postgresql { $::hostname :
        libdir => $libdir
      }
    }
    default : {
      fail( "unsupport db backend: ${db_backend}" )
    }
  }
}
