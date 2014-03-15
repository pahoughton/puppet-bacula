# gitolite.pp - 2014-02-22 08:56
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::dir::filesets::gitolite(
  $basedir = '/var/lib/gitolite'
  ) {
  bacula::fileset { 'gitolite' :
    include  => [ [ [$basedir],
                    [ 'compression = GZIP9',
                      'signature = MD5',
                      ],
                    ],
                  ],
  }
}
