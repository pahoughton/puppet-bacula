# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dir_host = undef,
  $workdir = '/var/lib/bacula/work',
  $max_jobs = 2,
  $package = 'bacula-storage'
  $service = 'bacula-sd'
  ) {

  
  exec { "mkdir -p ${workdir} - bacula::fd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => "${workdir}",
  }

  package { $package:
    ensure => installed,
  }
 
  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service[$service],
    require => Package[$package],
  }

  file { $sd_directory :
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
  }
  
  file { '/etc/bacula/bacula-sd.d':
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    before => Service[$service],
  }

  # Register the Service so we can manage it through Puppet
  service { $service:
    ensure     => 'running',
    enable     => true,
    require    => Package[$package],
  }
}
