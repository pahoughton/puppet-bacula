# schedule.pp - 2014-02-16 10:38
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::schedule (
  $configdir  = '/etc/bacula',
  $run        = undef,
  $template   = 'bacula/schedule.conf.erb',
  ) {

  $sched = $name ? {
    undef   => $title,
    default => $name,
  }

  file { "${configdir}/dir.d/sched-${sched}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => Class['bacula::dir'],
  }
}
