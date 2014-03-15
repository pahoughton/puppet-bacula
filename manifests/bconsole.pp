# bconsole.pp - 2014-02-17 13:01
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
class bacula::bconsole (
  $configdir = '/etc/bacula',
  $dir_host  = $::hostname,
  $dir_pass  = undef,
  $template  = 'bacula/bconsole.conf.erb',
  ) {

  $password = $dir_pass ? {
    undef   => "${dir_host}-dir-pass",
    default => $dir_pass,
  }
  package { 'bacula-console' :
    ensure => 'installed',
  }
  file { "${configdir}/bconsole.conf" :
    ensure  => 'file',
    content => template($template),
  }

}
