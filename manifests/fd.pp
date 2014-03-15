# fd.pp - 2014-02-16 07:27
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# This is installed on the client

class bacula::fd (
  $dir_host,
  $configdir  = '/etc/bacula',
  $piddir     = '/var/run/bacula',
  $libdir     = '/var/lib/bacula',
  $workdir    = '/srv/bacula/work',
  $package    = undef,
  $max_jobs   = 2,
  $service    = 'bacula-fd',
  $fd_only    = false,
  $template   = 'bacula/bacula-fd.conf.erb',
  ) {

  $fd_package = $package ? {
    undef   => $::osfamily ? {
      'debian' => 'bacula-fd',
      'RedHat' => 'bacula-client',
    },
    default => $package,
  }

  package { $fd_package :
    ensure => 'installed',
  }

  exec { "mkdir -p ${workdir} - bacula::fd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => $workdir,
  }

  if $fd_only {
    file { [$configdir,$rundir,$libdir,] :
      ensure  => 'directory',
      mode    => '0755',
    }
  }
  file { "${configdir}/bacula-fd.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$service],
    require => Package[$package],
  }
  service { $service :
    ensure  => 'running',
    enable  => true,
    require => File["${configdir}/bacula-fd.conf"],
  }
}
