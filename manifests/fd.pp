# fd.pp - 2014-02-16 07:27
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# This is installed on the client

class bacula::fd (
  $dir_host   = undef,
  $workdir    = '/var/lib/bacula/work',
  $piddir     = '/var/run/',
  $fd_package = undef,
  $template   = 'bacula/bacula-fd.conf.erb',
  $max_jobs   = 2,
  ) {
  
  $package = $fd_package ? {
    undef   => $::operatingsystem ? {
      'Ubuntu' => 'bacula-fd',
      default  => 'bacula-client',
    },
    default => $fd_package,
  }
  $service = 'bacula-fd'

  package { $package :
    ensure => 'installed',
  }
  
  exec { "mkdir -p ${workdir} - bacula::fd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => "${workdir}",
  }

  file { '/etc/bacula/bacula-fd.conf' :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$service],
    require => Package[$package],
  }
  service { $service :
    ensure  => 'running',
    enable  => true,
    require => File['/etc/bacula/bacula-fd.conf'],
  }
}
