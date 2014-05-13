# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# No spaces in subcomponent names.
class bacula::dir (
  $cfgdir          = '/etc/bacula',
  $piddir          = '/var/run/bacula',
  $libdir          = '/var/lib/bacula',
  $datadir         = '/srv/bacula',
  $db_srv_pass      = undef,
  $db_backend       = 'pgsql',
  $db_host          = 'localhost',
  $db_user          = 'bacula',
  $db_pass          = 'bacula',
  $db_name          = 'bacula',
  $max_jobs         = 5,
  $mail_to          = 'root@localhost',
  $sd_host          = undef,
  $user             = 'bacula',
  $group            = 'bacula',
  $db_os_user       = 'postgres',
  $db_os_group      = 'postgres',
  $manage_firewall  = false,
  ) {

  $directories = hiera('directories',{'bacula' => {
    'cfg'  => $cfgdir,
    'data' => $datadir,
    'lib'  => $libdir,
    'pid'  => $piddir,
    }}
  )
  $ports       = hiera('ports',{'bacula-sd' => '9101'})

  case $::operatingsystem {
    'Fedora' : {
      $packages     = ['bacula-director']
      $service  = 'bacula-dir'
    }
    'CentOS' : {
      $packages     = ["bacula-director-${db_backend}"]
      $service  = 'bacula-dir'
    }
    'Ubuntu' : {
      case $db_backend {
        'pgsql' : {
          $packages    = ['bacula-common-pgsql','bacula-director-pgsql']
        }
        default : {
          fail("Ubuntu unsupported db_backend ${db_backend}")
        }
      }
      $service    = 'bacula-director'
    }
  }

  ensure_packages([$packages])

  File {
    owner   => $user,
    group   => $group,
    notify  => Service[$service],
    require => Package[$packages],
  }

  class { 'bacula::dir::database' :
    srv_pass => $db_srv_pass,
    backend  => $db_backend,
    host     => $db_host,
    name     => $db_name,
    user     => $db_user,
    pass     => $db_pass,
  }

  $dircfg   = $directories['bacula']['cfg']
  $dirdata  = $directories['bacula']['data']
  $dirlib   = $directories['bacula']['lib']
  $dirscr   = "${directories['bacula']['lib']}/scripts"
  $dirpid   = $directories['bacula']['pid']
  $dirwork  = "${directories['bacula']['data']}/work"
  $dirrest  = "${directories['bacula']['data']}/restore"
  $dirpgsql = "${directories['bacula']['data']}/work/pgsql"
  $dirmysql = "${directories['bacula']['data']}/work/mysql"

  $dirs = [ $dircfg,
            $dirdata,
            $dirlib,
            $dirpid,
            $dirwork,
            $dirrest,
            ]

  ensure_resource('file',$dirs,{
    ensure  => 'directory',
    mode    => '0775',
    }
  )

  # used by template
  $queryfn = $::osfamily ? {
    'Debian'  => "${dircfg}/scripts/query.sql",
    default   => "${dircfg}/query.sql",
  }
  file { "${dircfg}/bacula-dir.conf" :
    ensure  => 'file',
    content => template('bacula/bacula-dir.conf.erb'),
  }

  file { "${dircfg}/dir.d" :
    ensure  => 'directory',
  }
  file { "${dircfg}/dir.d/empty.conf" :
    ensure  => 'file',
    content => "# empty\n",
  }

  service { $service :
    ensure => 'running',
    enable => true,
  }
  class { 'bacula::fd' :
    director      => $::hostname,
    pgsql_support => true,
    fd_only       => false,
  }
  bacula::dir::client { $::hostname :
    cfgdir => $dircfg,
  }
  class { 'bacula::bconsole' : }

  if $sd_host {
    bacula::dir::storage { 'Default' :
      sd_host    => $sd_host,
      device     => 'Default',
      media_type => 'File'
    }
  }
  ensure_resource('file',$dirrest,{
    ensure   => 'directory',
    mode     => '0775',
  })
  bacula::dir::job { 'Restore' :
    jtype           => 'Job',
    client          => $::hostname,
    type            => 'Restore',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    fileset         => 'FullSet',
    where           => $dirrest,
  }
  bacula::dir::job { 'Default' :
    jtype           => 'JobDefs',
    client          => $::hostname,
    type            => 'Backup',
    messages        => "${::hostname}-msg-standard",
    storage         => 'Default',
    pool            => 'Default',
    priority        => 10,
    write_bootstrap => "${dirwork}/%c.bsr",
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
  case $db_backend {
    'pgsql' : {
      bacula::dir::jobdefs::pgsql { $::hostname :
        libdir => $libdir
      }
    }
    default : {
      fail( "unsupport db backend: ${db_backend}" )
    }
  }
  if $manage_firewall {
    firewall { "${ports[bacula-dir]} accept - bacula-dir":
      port   => $ports['bacula-dir'],
      proto  => 'tcp',
      action => 'accept',
    }
  }
}
