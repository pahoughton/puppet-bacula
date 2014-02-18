# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dir_host = undef,
  $workdir  = '/var/lib/bacula/work',
  $max_jobs = 2,
  $package  = 'bacula-storage',
  $service  = 'bacula-sd',
  $default  = '/var/lib/bacula/backups',
  $template = 'bacula/bacula-sd.conf.erb'
  ) {

  
  exec { "mkdir -p ${workdir} - bacula::sd" :
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

  file { '/etc/bacula/bacula-sd.d':
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    before => Service[$service],
  }
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
    require    => Package[$package],
  }
  if $default {
    bacula::device::file { 'Default' :
      device => $default,
    }
  }
}
