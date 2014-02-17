# sd.pp - 2014-02-16 06:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $sd_directory = '/mnt/bacula/default',
  $db_backend = 'postgresql',
  $dir_host = undef,
  $max_jobs = 20,
  ) {

  case $db_backend {
    'postgresql' : {
      $sd_package = $::operatingsystem ? {
        'Fedora' => 'bacula-storage',
        'CentOS' => 'bacula-storage-postgresql',
        'Ubuntu' => 'bacula-storage-pgsql',
      }
    }
    'mysql' : {
      $sd_package = $::operatingsystem ? {
        'Fedora' => 'bacula-storage',
        'CentOS' => 'bacula-storage-mysql',
        'Ubuntu' => 'bacula-storage-mysql',
      }
    }
    'sqlite' : {
      $sd_package = $::operatingsystem ? {
        'Fedora' => 'bacula-storage',
        'CentOS' => 'bacula-storage-sqlite',
        'Ubuntu' => 'bacula-storage-sqlite3',
      }
    }
    default : {
      fail("Unsupported db_backend '${db_backend}'")
    }
  }
  package { $sd_package:
    ensure => installed,
  }
 
  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service['bacula-sd'],
    require => Package[$sd_package],
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
    before => Service['bacula-sd'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    ensure     => 'running',
    enable     => true,
    require    => Package[$sd_package],
  }
}
