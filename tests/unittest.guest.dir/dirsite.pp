# 2015-06-30 (cc) <paul4hough@gmail.com>
#
node default {
  notify { 'dir node default' : }
  class { 'bacula::dir' :
    sdaddr => 'tbacula-sd'
  }
  bacula::dir::node { 'tbacula-fd' : }
}
