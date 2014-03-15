# postgresql.pp - 2014-02-17 08:37
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
define bacula::dir::jobdefs::postgresql (
  $client,
  $libdir  = '/var/lib/bacula',
  $pool    = undef,
  $fileset = undef,
  $sched   = 'WeeklyCycle',
  $fileset = 'PostgresDefault',
  ) {
  bacula::job { $title :
    client         => $client,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched
    client_before  => "su -c '${libdir}/scripts/pgdump.bash' - postgres",
    client_after   => "su -c '${libdir}/scripts/pgclean.bash' - postgres",
  }
}
