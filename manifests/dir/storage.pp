# storage.pp - 2014-02-17 11:24
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::storage (
  $configdir   = '/etc/bacula',
  $sd_host     = undef,
  $port        = undef,
  $pass        = undef,
  $device      = 'File',
  $media_type  = 'File',
  $autochg     = undef,
  $max_jobs    = undef,
  $compr       = undef,
  $heart       = undef,
  $template    = 'bacula/storage.conf.erb',
  ) {

  $sd_name = $title

  $sd_pass = $pass ? {
    undef    => "${sd_host}-sd-pass",
    default  => $pass,
  }
  file { "${configdir}/dir.d/storage-${sd_name}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => File["${configdir}/dir.d"],
  }

}
