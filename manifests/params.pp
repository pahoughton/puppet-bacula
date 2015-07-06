# 2015-07-01 (cc) <paul4hough@gmail.com>
#
class bacula::params (
  $dirname    = 'bacula-dir', # bacula director name
  $configdir  = '/etc/bacula',
  $rundir     = '/var/run/bacula',
  $libdir     = '/var/lib/bacula',
  $workdir    = '/var/lib/bacula/work',
  $restoredir = '/var/tmp',
  $user       = 'bacula',
  $group      = 'bacula',
  $db_srv_pass      = undef,
  $db_backend       = 'postgresql',
  $db_host          = 'localhost',
  $db_user          = 'bacula',
  $db_pass          = 'bacula',
  $db_name          = 'bacula',
  $pg_dumpdir       = '/srv/postgres/dump', # Fixme
  $max_jobs         = 5,
  $mail_to          = 'root@localhost',
  $sd_host          = undef,
  $db_nix_user  = 'postgres',
  $db_nix_group = 'postgres',
  ) {
}
