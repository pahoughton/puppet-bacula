# fileset.pp - 2014-02-16 13:32
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Fixme ugly include data structure
define bacula::fileset (
  $ignore_changes = undef,
  $enable_vss     = undef,
  $include        = undef,
  $options        = undef,
  $excludes       = undef,
  $template       = 'bacula/fileset.conf.erb',
  ) {
  $fileset = $name ? {
    undef   => "${title}",
    default => $name,
  }

  file { "/etc/bacula/bacula-dir.conf.d/${fileset}-fileset.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => Class['bacula::dir'],
  }
}
  
