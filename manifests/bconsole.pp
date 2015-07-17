# bconsole.pp - 2014-02-17 13:01
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::bconsole (
  $dirname   = $::bacula::params::dirname,
  $dirpass   = $::bacula::params::dirpass,
  $configdir = $::bacula::params::configdir,
  $diraddr   = $::hostname,
  $template  = 'bacula/bconsole.conf.erb',
  ) inherits ::bacula::params {

  package { 'bacula-console' :
    ensure => 'installed',
  }
  file { "${configdir}/bconsole.conf" :
    ensure  => 'file',
    content => template($template),
  }

}
