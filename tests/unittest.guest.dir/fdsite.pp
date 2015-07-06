# 2015-07-03 (cc) <paul4hough@gmail.com>
#
node default {
  notify { 'fd node default' : }
  class { 'bacula::fd' : }
}
