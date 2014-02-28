# dir_client.pp - 2014-02-16 09:55
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Director client - part of Director configuration.

define bacula::dir::client (
  $f_retention = '60 days',
  $j_retention = '60 days',
  $auto_prune  = 'yes',
  $max_jobs    = '5',
  $template    = 'bacula/client.conf.erb',
  ) {
  
  $fd_host = $name ? {
    undef   => "${title}",
    default => $name,
  }

  file { "/etc/bacula/bacula-dir.d/client-${fd_host}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => File['/etc/bacula/bacula-dir.d/'],
  }
}
