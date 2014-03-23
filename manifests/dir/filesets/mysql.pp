# mysql.pp - 2014-03-18 03:58
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::filesets::mysql (
  $libdir = '/var/lib/bacula',
  ) {
  $client = $title
  bacula::dir::fileset { "mysql-${client}" :
    include => [  [ [ "|${libdir}/scripts/mylist.bash",
                      ],
                    [ 'signature = MD5',
                      'readfifo = yes'
                      ],
                    ],
                  ],
  }
}
