# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $director        = 'localhost',
  $cfgdir          = '/etc/bacula',
  $piddir          = '/var/run/bacula',
  $libdir          = '/var/lib/bacula',
  $datadir         = '/srv/bacula',
  $bkupdir         = '/srv/bacula/backup',
  $packages        = undef,
  $max_jobs        = 2,
  $service         = 'bacula-sd',
  $user            = 'bacula',
  $group           = 'bacula',
  $auto_label      = undef,
  $is_dir          = undef,
  $manage_firewall = false,
  $template        = 'bacula/bacula-sd.conf.erb'
  ) {

  $directories = hiera('directories',{'bacula' => {
    'bkup' => $bkupdir,
    'cfg'  => $cfgdir,
    'data' => $datadir,
    'lib'  => $libdir,
    'pid'  => $piddir,
    }}
  )
  $servers     = hiera('servers',{'bacula-dir' => $director })
  $groups      = hiera('groups',{'bacula' => $group })
  $users       = hiera('users',{'bacula' => $user })
  $ports       = hiera('ports',{'bacula-sd' => '9103'})

  $pkgs = $packages ? {
    undef      => $::operatingsystem ? {
      'CentOS' => [ 'bacula-storage-common',
                    'bacula-storage-mysql',
                    'bacula-storage-postgresql',
                    ],
      'Ubuntu' => ['bacula-sd-pgsql'],
      default  => ['bacula-storage',],
    },
    default    => $packages,
  }

  ensure_packages($pkgs)

  File {
    owner   => $users['baula'],
    group   => $groups['bacula'],
    require => Package[$pkgs],
  }

  $dircfg   = $directories['bacula']['cfg']
  $dirdata  = $directories['bacula']['data']
  $dirlib   = $directories['bacula']['lib']
  $dirscr   = "${directories['bacula']['lib']}/scripts"
  $dirsdcfg = "${directories['bacula']['cfg']}/sd.d"
  $dirpid   = $directories['bacula']['pid']
  $dirwork  = "${directories['bacula']['data']}/work"
  $dirbkup  = "${directories['bacula']['bkup']}"

  $dirs = [ $dircfg,
            $dirdata,
            $dirlib,
            $dirpid,
            $dirsdcfg,
            $dirwork,
            ]

  ensure_resource('file',$dirs,{
    ensure  => 'directory',
    mode    => '0775',
    }
  )
  file { "${dirsdcfg}/empty.conf" :
    ensure  => 'file',
    content => "# empty\n",
    require => File[$dirsdcfg],
  }
  ensure_resource('file',"${dircfg}/bacula-sd.conf",{
    ensure  => 'file',
    mode    => '0664',
    content => template($template),
    notify  => Service[$service],
  })

  ensure_resource('service',$service,{
    ensure  => 'running',
    enable  => true,
    require => File["${dircfg}/bacula-sd.conf"],
  })


  if $dirbkup {
    $label_media = $auto_label ? {
        true    => 'Yes',
        default => undef,
    }
    bacula::sd::device::file { 'Default' :
      device      => $dirbkup,
      label_media => $label_media
    }
  }

  if $manage_firewall {
    firewall { "${ports[bacula-sd]} accept - bacula-sd":
      port   => $ports['bacula-sd'],
      proto  => 'tcp',
      action => 'accept',
    }
  }
}
