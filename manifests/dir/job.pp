# job.pp - 2014-02-16 10:46
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::job (
  $client            = undef, # defaults to title
  $configdir         = '/etc/bacula',
  $fileset           = undef,
  $jtype             = 'Job',
  $type              = 'Backup',
  $level             = undef,
  $accurate          = undef,
  $verify_job        = undef,
  $jobdefs           = 'Default',
  $bootstrap         = undef,
  $write_bootstrap   = undef,
  $messages          = $::bacula::params::jobmesgs,
  $pool              = undef,
  $full_pool         = undef,
  $diff_pool         = undef,
  $incr_pool         = undef,
  $sched             = undef,
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

  include ::bacula::params

  $bclient = $client ? {
    undef   => $title,
    default => $client,
  }

  file { "${configdir}/dir.d/${jtype}-${title}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => [File["${configdir}/dir.d"],
                Class[::bacula::params]],
  }

}
