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
  ) {
  
  $package = $fd_package ? {
    undef   => 'bacula-fd',
    default => $fd_package,
  }
  $service = 'bacula-fd'
  
  package { $package :
    ensure => 'installed',
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
