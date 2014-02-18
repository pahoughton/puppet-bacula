# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dir_host = undef,
  $workdir  = '/var/lib/bacula/work',
  $max_jobs = 2,
  $packages = undef,
  $service  = 'bacula-sd',
  $default  = '/var/lib/bacula/backups',
  $template = 'bacula/bacula-sd.conf.erb'
  ) {
  
  exec { "mkdir -p ${workdir} - bacula::sd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => "${workdir}",
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
 
  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service[$service],
    require => Package[$sd_packages],
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    before => Service[$service],
    require => Package[$sd_packages]
  }->
  file { '/etc/bacula/bacula-sd.d/empty.conf' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => "# empty\n",
    before  => Service[$service],
  }
  # Register the Service so we can manage it through Puppet
  service { $service :
    ensure     => 'running',
    enable     => true,
    require    => Package[$sd_packages],
  }
  if $default {
    bacula::device::file { 'Default' :
      device => $default,
    }
  }
}
