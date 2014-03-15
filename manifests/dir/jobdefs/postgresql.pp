# postgresql.pp - 2014-02-17 08:37
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
define bacula::jobdefs::postgresql (
  $client,
  $pool = undef,
  $fileset = undef,
  $sched = undef
  ) {
  bacula::job { $title :
    client         => $client,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset ? {
      undef   => 'PostgresDefault',
      default => $fileset,
    },
    sched          => $sched ? {
      undef   => 'WeeklyCycle',
      default => $sched,
    },
    client_before  => "su -c '/etc/bacula/scripts/pgdump.bash' - postgres",
    client_after   => "su -c '/etc/bacula/scripts/pgclean.bash' - postgres",
  }
}
