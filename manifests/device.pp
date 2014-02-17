# device.pp - 2014-02-16 22:41
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::device (
  $name = undef,
  $device= undef,
  $type= undef,
  $media_type= undef,
  $auto_chg= undef,
  $chg_dev= undef,
  $chd_cmd= undef,
  $alert_cmd= undef,
  $drv_idx= undef,
  $auto_select= undef,
  $max_chg_wait= undef,
  $max_rw_wait= undef,
  $max_open_wait= undef,
  $always_open= undef,
  $vol_poll= undef,
  $close_poll= undef,
  $removable= undef,
  $random= undef,
  $req_mount= undef,
  $auto_mount = undef,
  $mnt_point= undef,
  $mnt_cmd= undef,
  $umnt_cmd= undef,
  $min_blk_size= undef,
  $max_blk_size= undef,
  $heom= undef,
  $ffspace= undef,
  $mtioc= undef,
  $bsf_eom= undef,
  $two_eof= undef,
  $bsr= undef,
  $bsf= undef,
  $fsr= undef,
  $fsf= undef,
  $offline= undef,
  $max_jobs= undef,
  $max_vol_size= undef,
  $max_file_size= undef,
  $blocking= undef,
  $max_net_buf= undef,
  $max_spool= undef,
  $max_job_spool= undef,
  $spool_dir= undef,
  $max_part= undef,
  $template = 'bacula/device.conf.erb',
  ) {

  $service = 'bacula-sd'
  $package = 'bacula-storage'
  
  package { $package :
    ensure => 'installed',
  }
  $device = $name ? {
    undef   => "${title}",
    default => "${name}",
  }
  file { "/etc/bacula/bacula-sdd.conf.d/device-${device}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$service],
    require => Package[$package],
  }
}
