# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::database (
  $backend = 'postgresql',
  $user = 'bacula',
  $pass = 'bacula',
) {

  case $backend {
    'postgresql' : {
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }
}
