# pool.pp - 2014-02-16 13:16
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::pool (
  $type,
  $storage,
  $use_once,
  $max_vol_jobs,
  $max_vol_files,
  $max_vol_bytes,
  $vol_use_dur,
  $catalog_files,
  $auto_prune,
  $vol_retent,
  $scratch_pool,
  $recycle_pool,
  $recycle,
  $recycle_oldest,
  $recycle_current,
  $purge_oldest,
  $cleaning_prefix,
  $label_format,
  $template = 'bacula/pool.conf.erb'
  ) {
  $pool = $name ? {
    undef   => "${title}",
    default => $name,
  }

  file { "/etc/bacula/bacula-dir.conf.d/pool-${pool}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => Class['bacula::dir'],
  }

}
