# gitolite.pp - 2014-02-22 08:54
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::jobdefs::gitolite (
  $client  = undef,
  $basedir = '/srv/gitolite',
  $pool    = undef,
  $sched   = 'WeeklyCycle',
  ) {

  $jclient = $client ? {
    undef   => $title,
    default => $client,
  }
  $fileset = "gitolite-${jclient}"

  bacula::dir::filesets::gitolite { $jclient :
    basedir        => $basedir,
  }->
  bacula::dir::job { "gitolite-${jclient}" :
    client         => $jclient,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched,
    client_before  => "su - git -c '${basedir}/bin/gitolite writable @all off backup'",
    client_after   => "su - git -c '${basedir}/bin/gitolite writable @all on'",
  }
}
