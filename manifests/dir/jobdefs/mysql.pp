# mysql.pp - 2014-03-17 16:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::jobdefs::mysql (
  $client  = undef,
  $libdir  = '/var/lib/bacula',
  $pool    = undef,
  $sched   = 'WeeklyCycle',
  ) {

  $jclient = $client ? {
    undef   => $title,
    default => $client,
  }
  $fileset = "mysql-${jclient}"

  bacula::dir::filesets::mysql { $jclient :
    libdir        => $libdir,
  }->
  bacula::dir::job { "mysql-${jclient}" :
    client         => $client,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched,
    client_before  => "${libdir}/scripts/mydump.bash",
    client_after   => "${libdir}/scripts/myclean.bash",
  }
}
