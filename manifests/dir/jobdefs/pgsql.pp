# pgsql.pp - 2014-02-17 08:37
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::jobdefs::pgsql (
  $client    = undef,
  $libdir    = '/var/lib/bacula',
  $pool      = undef,
  $dump_user = undef,
  $sched     = 'WeeklyCycle',
  ) {

  $jclient = $client ? {
    undef   => $title,
    default => $client,
  }
  $user = $dump_user ? {
    undef => $::operatingsystem ? {
      'Darwin' => '_postgres',
      default  => 'postgres',
    },
    default => $dump_user,
  }
  $fileset   = "pgsql-${jclient}"

  bacula::dir::filesets::postgresql { $jclient :
    dump_user => $user,
    libdir    => $libdir,
  }->
  bacula::dir::job { "pgsql-${jclient}" :
    client         => $client,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched,
    client_before  => "su -c '${libdir}/scripts/pgdump.bash' - ${user}",
    client_after   => "su -c '${libdir}/scripts/pgclean.bash' - ${user}",
  }
}
