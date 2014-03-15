# pool.pp - 2014-02-16 13:16
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::pool (
  $confdir           = '/etc/bacula',
  $type              = 'Backup',
  $storage           = undef,
  $use_once          = undef,
  $max_vol_jobs      = undef,
  $max_vol_files     = undef,
  $max_vol_bytes     = undef,
  $vol_use_dur       = undef,
  $catalog_files     = undef,
  $auto_prune        = undef,
  $vol_retent        = undef,
  $scratch_pool      = undef,
  $recycle_pool      = undef,
  $recycle           = undef,
  $recycle_oldest    = undef,
  $recycle_current   = undef,
  $purge_oldest      = undef,
  $cleaning_prefix   = undef,
  $label_format      = undef,
  $template          = 'bacula/pool.conf.erb'
  ) {

  $pool = $name ? {
    undef   => $title,
    default => $name,
  }

  file { "${confdir}/dir.d/pool-${pool}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => File["${confdir}/bacula/dir.d"],
  }

}
