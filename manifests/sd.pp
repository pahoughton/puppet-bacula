# sd.pp - 2014-02-16 06:34
#
# Copyright (cc) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::sd (
  $dirname    = $::bacula::params::dirname,
  $configdir  = $::bacula::params::configdir,
  $rundir     = '/var/run',
  $libdir     = $::bacula::params::libdir,
  $workdir    = $::bacula::params::workdir,
  $backupdir  = '/var/lib/bacula/backups',
  $max_jobs   = 2,
  $packages   = undef,
  $service    = 'bacula-sd',
  $user       = $::bacula::params::user,
  $group      = $::bacula::params::group,
  $sdname     = $::hostname,
  $password   = 'bacsdpass',
  $auto_label = undef,
  $is_dir     = undef,
  $template   = 'bacula/bacula-sd.conf.erb'
  ) inherits ::bacula::params {

  File {
    owner   => $user,
    group   => $group,
  }

  if $packages == undef {
    case $::operatingsystem {
      'CentOS' : {
        $sd_packages = ['bacula-storage-common',
                        'bacula-storage-postgresql',]
      }
      'Fedora', 'RedHat' : {
        $sd_packages = ['bacula-storage',]
      }
      'Ubuntu' : {
        $sd_packages = ['bacula-sd-pgsql']
      }
      default : {
        fail("Unsupported ::operatingsystem '${::operatingsystem}'")
      }
    }
  } else {
    $sd_packages = $packages
  }
  package { $sd_packages:
    ensure => installed,
  }

  exec { "mkdir -p ${workdir} - bacula::sd" :
    command => "/bin/mkdir -p '${workdir}'",
    creates => $workdir,
  }
  ->
  file { $workdir :
    ensure  => 'directory',
    require => Package[$sd_packages],
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

  file { "${backupdir}" :
    ensure  => 'directory',
    before  => Service[$service],
    require => Package[$sd_packages]
  }
  # Register the Service so we can manage it through Puppet
  service { $service :
    ensure     => 'running',
    enable     => true,
    require    => File["${configdir}/sd.d/empty.conf"],
  }
  if $backupdir {
    $label_media = $auto_label ? {
        true    => 'Yes',
        default => undef,
    }
    bacula::sd::device::file { 'sd-default-backupdir' :
      device      => $backupdir,
      label_media => $label_media
    }
  }
}
