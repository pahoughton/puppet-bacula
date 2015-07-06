#!/bin/bash
# 2015-07-03 (cc) <paul4hough@gmail.com>
#
status=0

[ -z "$DEBUG" ] || set -x

function Dbg {
  [ -n "$DEBUG" ] && echo $@
}

function Die {
  echo Error - $? - $@
  exit 1
}
#DoOrDie
function DoD {
  $@ || Die $@
}

DoD yum -y install puppet
DoD puppet apply --modulepath=/root/unittest/modules unittest/fdsite.pp

exit $status
