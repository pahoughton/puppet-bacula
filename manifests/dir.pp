# director.pp - 2014-02-15 14:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::dirs (
  $db_backend = 'postgresql',
  $db_host    = 'localhost',
  $db_user    = 'bacula',
  $db_pass    = 'bacula',
  $db_name    = 'bacula',
  $max_jobs   = 5,
  ) {
  if $db_host == 'localhost' || $db_host == "${::hostname}" {
    class bacula::database { 'bacula' :
      backend => $db_backend,
      user  => $db_user,
      pass  => $db_pass,
    }
  }
  $service = 'bacula-dir'
  
  if $::operatingsystem == 'Fedora' {
    $package = 'bacula-director'
  } else {
    $package = "bacula-director-${db_backend}"
  }
  package { $package :
    ensure => 'installed',
  }
  file { ['/var/run/bacula','/var/lib/bacula',] :
    ensure  => 'directory',
    owner   => 'bacula',
    group   => 'bacula',
  }
  file { '/etc/bacula/bacula-dir.conf' :
    ensure  => 'file',
    owner   => 'bacula',
    group   => 'bacula',
    content => template('bacula/bacula-dir.conf.erb'),
    notify  => Service[$service],
    require => Package[$package],
  }
  
  file { '/etc/bacula/bacula-dir.d' :
    ensure  => 'directory',
    owner   => 'bacula',
    group   => 'bacula',
    before  => Service[$service],
    require => Package[$package],
  }
  
  service { $service :
    ensure => 'running',
    enable => true,
  }
}
