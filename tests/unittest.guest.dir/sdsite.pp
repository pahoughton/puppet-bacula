# 2015-06-30 (cc) <paul4hough@gmail.com>
#
node default {
  notify { 'sd node default' : }
  class { 'bacula::sd' : }
}
