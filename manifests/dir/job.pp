# job.pp - 2014-02-16 10:46
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::job (
  $client,
  $configdir         = '/etc/bacula',
  $fileset           = undef,
  $jtype             = 'Job',
  $type              = 'Backup',
  $level             = 'Full',
  $accurate          = undef,
  $verify_job        = undef,
  $jobdefs           = 'Default',
  $bootstrap         = undef,
  $write_bootstrap   = undef,
  $messages          = undef,
  $pool              = undef,
  $full_pool         = undef,
  $diff_pool         = undef,
  $incr_pool         = undef,
  $sched             = 'WeeklyCycle',
  $storage           = undef,
  $max_delay         = undef,
  $max_run           = undef,
  $incr_max_run      = undef,
  $max_wait          = undef,
  $id_max_wait       = undef,
  $diff_max_wait     = undef,
  $max_sched         = undef,
  $max_full_age      = undef,
  $pref_mounted      = undef,
  $prune_jobs        = undef,
  $prune_files       = undef,
  $prune_volumes     = undef,
  $run_script        = undef,
  $before_script     = undef,
  $after_script      = undef,
  $after_fail        = undef,
  $client_before     = undef,
  $client_after      = undef,
  $rerun_fail        = undef,
  $spool             = undef,
  $spool_attr        = undef,
  $where             = undef,
  $add_prefix        = undef,
  $add_suffix        = undef,
  $strip_prefix      = undef,
  $regex_where       = undef,
  $replace           = undef,
  $prefix_links      = undef,
  $max_jobs          = undef,
  $resched           = undef,
  $resched_interval  = undef,
  $resched_times     = undef,
  $run               = undef,
  $priority          = undef,
  $mixed_pri         = undef,
  $write_part        = undef,
  $template          = 'bacula/job.conf.erb',

  ) {

  $job = $name ? {
    undef   => $title,
    default => $name,
  }

  file { "${configdir}/dir.d/${jtype}-${job}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => File["${configdir}/dir.d"],
  }

}
