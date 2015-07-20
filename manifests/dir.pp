# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# No spaces in subcomponent names.
class bacula::dir (
  $dirname       = $::bacula::params::dirname,
  $dirpass       = $::bacula::params::dirpass,
  $configdir     = $::bacula::params::configdir,
  $rundir        = '/var/run/bacula',
  $libdir        = $::bacula::params::libdir,
  $workdir       = $::bacula::params::workdir,
  $restoredir    = $::bacula::params::restoredir,
  $max_jobs      = 5,
  $packages      = $::bacula::params::dirpkgs,
  $service       = $::bacula::params::dirsvc,
  $mail_to       = 'root@localhost',
  $user          = $::bacula::params::user,
  $group         = $::bacula::params::group,
  $catalogname   = $::bacula::params::catalogname,
  $dbbackend     = $::bacula::params::dbbackend,
  $install_dbsrv = $::bacula::params::install_dbsrv,
  $dbsrv_pass    = $::bacula::params::dbrv_pass,
  $dbhost        = $::bacula::params::dbhost,
  $dbname        = $::bacula::params::dbname,
  $dbuser        = $::bacula::params::dbuser,
  $dbpass        = $::bacula::params::dbpass,
  $jobmesgs      = $::bacula::params::jobmesgs,
  $sdaddr        = $::bacula::params::sdaddr,
  ) inherits ::bacula::params {


  package { $packages :
    ensure => 'installed',
  }

  File {
    owner   => $user,
    group   => $group,
    notify  => Service[$service],
    require => Package[$packages],
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

  class { 'bacula::dir::database' :
    backend     => $dbbackend,
    install_srv => $install_dbbackend,
    srv_pass    => $dbsrv_pass,
    host        => $dbhost,
    user        => $dbuser,
    pass        => $dbpass,
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
    require => [Package[$packages],
                File["${configdir}/bacula-dir.conf"]],
  }
  class { 'bacula::fd' :
    dirname       => "${::hostname}-dir",
    fd_only       => false,
  }
  class { 'bacula::bconsole' : }

  if $sdaddr {
    bacula::dir::storage { 'Default' :
      sd_host    => $sdaddr,
      device     => 'sd-default-backupdir',
      media_type => 'File'
    }
  }
  bacula::dir::pool { 'Default' :
    recycle       => 'yes',
    auto_prune    => 'yes',
    vol_retent    => '30 days',
    max_vol_bytes => '100G',
    label_format  => "${::hostname}.backup.vol.",
  }

  bacula::dir::job { 'Restore' :
    jtype           => 'Job',
    client          => $::hostname,
    type            => 'Restore',
    storage         => 'Default',
    pool            => 'Default',
    fileset         => 'FullSet',
    where           => $restoredir,
  }
  bacula::dir::job { 'Default' :
    jtype           => 'JobDefs',
    type            => 'Backup',
    storage         => 'Default',
    pool            => 'Default',
    priority        => 10,
    write_bootstrap => "${workdir}/%c.bsr",
  }
  bacula::dir::fileset { 'BacCatalog' :
    includes => [ [ ['/var/spool/bacula/bacula.sql'],['signature = MD5'] ] ],
  }

  bacula::dir::job { 'bacula-catalog' :
    jtype           => 'Job',
    client          => $::hostname,
    fileset         => 'BacCatalog',
    client_before   => "/usr/libexec/bacula/make_catalog_backup.pl ${catalogname}",
    client_after    => '/usr/libexec/bacula/delete_catalog_backup',
    write_bootstrap => '/var/spool/bacula/%n.bsr',
  }

  bacula::dir::fileset { 'FullSet' :
    includes => [ [ ['/etc','/srv','/home'],['signature = MD5'] ] ],
  }
  bacula::dir::client { $::hostname : }
  bacula::dir::job { $::hostname :
    fileset => 'FullSet',
    client  => $::hostname,
  }
}
