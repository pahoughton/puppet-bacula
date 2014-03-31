# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dir_host   = $::hostname,
  $configdir  = '/etc/bacula',
  $rundir     = '/var/run/bacula',
  $libdir     = '/var/lib/bacula',
  $workdir    = '/srv/bacula/work',
  $backupdir  = '/srv/bacula/backups',
  $max_jobs   = 2,
  $packages   = undef,
  $service    = 'bacula-sd',
  $user       = 'bacula',
  $group      = 'bacula',
  $auto_label = undef,
  $is_dir     = undef,
  $template   = 'bacula/bacula-sd.conf.erb'
  ) {

  File {
    owner   => $user,
    group   => $group,
  }

  exec { "mkdir -p ${workdir} - bacula::sd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => $workdir,
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
      default : {
        faile("Unsupported ::operatingsystem '${::operatingsystem}'")
      }
    }
  } else {
    $sd_packages = $packages
  }
  package { $sd_packages:
    ensure => installed,
  }

  file { "${configdir}/bacula-sd.conf" :
    ensure  => file,
    content => template($template),
    notify  => Service[$service],
    require => Package[$sd_packages]
  }
  file { "${configdir}/sd.d" :
    ensure  => 'directory',
    before  => Service[$service],
    require => Package[$sd_packages]
  }->
  file { "${configdir}/sd.d/empty.conf" :
    ensure  => 'file',
    content => "# empty\n",
    before  => Service[$service],
  }
  # Register the Service so we can manage it through Puppet
  service { $service :
    ensure     => 'running',
    enable     => true,
    require    => [Package[$sd_packages]]
  }
  if $backupdir {
    $label_media = $auto_label ? {
        true    => 'Yes',
        default => undef,
    }
    bacula::sd::device::file { 'Default' :
      device      => $backupdir,
      label_media => $label_media
    }
  }
}
