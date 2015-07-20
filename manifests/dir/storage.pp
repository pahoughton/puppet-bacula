# storage.pp - 2014-02-17 11:24
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::storage (
  $configdir   = '/etc/bacula',
  $sd_host     = undef,
  $port        = undef,
  $password    = 'bacsdpass',
  $device      = 'sd-default-backupdir',
  $media_type  = 'File',
  $autochg     = undef,
  $max_jobs    = undef,
  $compr       = undef,
  $heart       = undef,
  $template    = 'bacula/storage.conf.erb',
  ) {

  include ::bacula::params

  $sd_name = $title

  file { "${configdir}/dir.d/storage-${sd_name}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => [File["${configdir}/dir.d"],
                Class[bacula::params],],
  }

}
