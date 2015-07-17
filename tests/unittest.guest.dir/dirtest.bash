#!/bin/bash
# 2015-07-14 (cc) <paul4hough@gmail.com>
#
DEBUG=1
[ -n "$DEBUG" ] && set -x
targs="$0 $@"
# cfg
baseimg="/var/lib/libvirt/images/r6test-base.qcow2"
ssh_opts="-i tester.id -o StrictHostKeyChecking=no"

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

# perform a backup and restore of director and client nodes

bconsole <<EOF
@output /dev/null
messages
@output /tmp/bac.backup.$$.out
run job=tbacula-fd yes
wait
messages
@#
@# now do a restore
@#
@output /tmp/bac.restore.$$.out
restore current all
yes
wait
messages
@output
quit
EOF

cat /tmp/bac.backup.$$.out
cat /tmp/bac.restore.$$.out

Die Test not configured
