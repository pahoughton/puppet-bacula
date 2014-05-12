# pgsql.pp - 2014-03-17 16:41
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::filesets::pgsql (
  $client    = undef,
  $dump_user = undef,
  $libdir    = $bacula::dir::libdir,
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

  bacula::dir::fileset { "pgsql-${jclient}" :
    include => [  [ [ "|su -c '${libdir}/scripts/pglist.bash' - ${user}",
                      ],
                    [ 'signature = MD5',
                      'readfifo = yes'
                      ],
                    ],
                  ],
  }
}
