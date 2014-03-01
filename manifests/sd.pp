# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dir_host   = undef,
  $work_dir    = '/var/lib/bacula/work',
  $max_jobs   = 2,
  $packages   = undef,
  $service    = 'bacula-sd',
  $user       = 'bacula',
  $group      = 'bacula',
  $default    = '/var/lib/bacula/backups',
  $auto_label = undef,
  $is_dir     = true,
  $template   = 'bacula/bacula-sd.conf.erb'
  ) {

  File {
    owner   => $user,
    group   => $group,
  }
  
  exec { "mkdir -p ${work_dir} - bacula::sd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => $work_dir,
  }
  if $packages == undef {
    case $::operatingsystem {
      'CentOS' : {
        $sd_packages = ['bacula-storage-common',
                        'bacula-storage-mysql',
                        'bacula-storage-postgresql',]
      }
      'Fedora' : {
        $sd_packages = ['bacula-storage',]
      }
      'Ubuntu' : {
        $sd_packages = ['bacula-sd-pgsql']
      }
    }
  } else {
    $sd_packages = $packages
  }
  package { $sd_packages:
    ensure => installed,
  }

  if !$is_dir {
    file { ['/var/run/bacula',
            '/var/lib/bacula',
            ] :
              ensure  => 'directory',
    }
  }
  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    content => template($template),
    notify  => Service[$service],
    require => Package[$sd_packages]
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure => directory,
    before => Service[$service],
    require => Package[$sd_packages]
  }->
  file { '/etc/bacula/bacula-sd.d/empty.conf' :
    ensure  => 'file',
    content => "# empty\n",
    before  => Service[$service],
  }
  # Register the Service so we can manage it through Puppet
  service { $service :
    ensure     => 'running',
    enable     => true,
    require    => [Package[$sd_packages],File['/var/run/bacula']]
  }
  if $default {
    bacula::device::file { 'Default' :
      device => $default,
      label_media => $auto_label ? {
        true    => 'Yes',
        default => undef,
      },
    }
  }
}
