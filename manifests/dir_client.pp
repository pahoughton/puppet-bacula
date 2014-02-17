# dir_client.pp - 2014-02-16 09:55
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Director client - part of Director configuration.

define bacula::dir_client (
  $name        = undef,
  $f_retention = '60 days',
  $j_retention = '60 days',
  $auto_prune  = 'yes',
  $max_jobs    = '5',
  $priority    = '10',
  $dir_service = 'bacula-dir',
  $template    = 'bacula/client.conf.erb',
  ) {
  
  $fd_host = $name ? {
    undef   => "${title}",
    default => $name,
  }

  file { "/etc/bacula/bacula-dir.conf.d/${name}-client.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$dir_service],
    require => Class['bacula::dir'],
  }
}
