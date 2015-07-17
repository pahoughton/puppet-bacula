# dir_client.pp - 2014-02-16 09:55
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Director client - part of Director configuration.

define bacula::dir::client (
  $configdir   = $::bacula::params::configdir,
  $file_ret    = '60 days',
  $job_ret     = '60 days',
  $auto_prune  = 'yes',
  $max_jobs    = '5',
  $password    = $::bacula::params::fdpass,
  $catalogname = $::bacula::params::catalogname,
  $template    = 'bacula/client.conf.erb',
  ) {

  include ::bacula::params

  $fdname = $name ? {
    undef   => $title,
    default => $name,
  }

  file { "${configdir}/dir.d/client-${fdname}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => [File["${configdir}/dir.d/"],
                Class[bacula::params]
                ]
  }
}
