# 2015-07-01 (cc) <paul4hough@gmail.com>
#
class bacula::params (
  $dirname    = 'bacula-dir', # bacula director name
  $configdir  = '/etc/bacula',
  $rundir     = '/var/run/bacula',
  $libdir     = '/var/lib/bacula',
  $workdir    = '/srv/bacula/work',
  $user       = 'bacula',
  $group      = 'bacula',
  ) {
}
