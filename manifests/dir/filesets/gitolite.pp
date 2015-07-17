# gitolite.pp - 2014-02-22 08:56
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define bacula::dir::filesets::gitolite (
  $basedir = '/var/lib/gitolite'
  ) {
  $client = $title
  bacula::dir::fileset { "gitolite-${client}" :
    includes  => [ [ [$basedir],
                    [ 'compression = GZIP9',
                      'signature = MD5',
                      ],
                    ],
                  ],
  }
}
