# gitolite.pp - 2014-02-22 08:54
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::jobdefs::gitolite (
  $client,
  $basedir = '/var/lib/gitolite',
  $pool    = undef,
  $fileset = 'gitolite',
  $sched   = undef
  ) {

  class { bacula::filesets::gitolite :
    basedir        => $basedir,
  }->
  bacula::job { $title :
    client         => $client,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched ? {
      undef   => 'WeeklyCycle',
      default => $sched,
    },
    client_before  => "su - git -c '${basedir}/bin/gitolite writable @all off backup'",
    client_after   => "su - git -c '${basedir}/bin/gitolite writable @all on'",
  }
}
