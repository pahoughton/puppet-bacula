# schedule.pp - 2014-02-16 10:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::schedule (
  $name,
  $run = undef,
  ) {
  
  $sched = $name ? {
    undef   => "${title}",
    default => $name,
  }

  file { "/etc/bacula/bacula-dir.conf.d/sched-${sched}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$dir_service],
    require => Class['bacula::dir'],
  }
}
