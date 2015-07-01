#!/bin/bash
# 2015-06-22 (cc) <paul4hough@gmail.com>
#
status=0

function Dbg {
  [ -n "$DEBUG" ] && echo $@
}

function Die {
  echo Error - $? - $@
  virsh shutdown $guestname
  chmod 644 tester.id
  exit 1
}
#DoOrDie
function DoD {
  $@ || Die $@
}

DoD yum -y install puppet

DoD puppet apply unittest/unittest.pp

exit $status
