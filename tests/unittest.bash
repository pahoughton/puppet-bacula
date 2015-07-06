#!/bin/bash
# 2015-06-01 (cc) <paul4hough@gmail.com>
#
# FIXME - need a lock step for renaming vm
#
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
  virsh shutdown tbacula-dir
  virsh shutdown tbacula-sd
  virsh shutdown tbacula-fd
  # chmod 644 tester.id
  exit 1
}
#DoOrDie
function DoD {
  $@ || Die $@
}

function start-libvirt-guest {
  guestname=$1
  guestnum=$2
  imgfn=`pwd`/$guestname.qcow2

  if [ -z "$REUSE" -o ! -f "$imgfn" ] ; then
    # echo $imgfn
    DoD cp "$baseimg" "$imgfn"
    DoD chmod +w "$imgfn"

    sed  \
      -e "s~%imgfn%~$imgfn~g" \
      -e "s~%guestname%~$guestname~g" \
      -e "s~%guestnum%~$guestnum~g" \
      test.xml.tmpl > $guestname.xml
  fi

  DoD chmod 600 tester.id
  DoD virsh create $guestname.xml
  DoD sleep 30

  vgip=
  while [ -z "$vgip" ]; do
    vgip=`awk -e "/52:54:00:c8:aa:$guestnum/ "'{print $3}' /var/lib/libvirt/dnsmasq/default.leases`
    if [ -n "$vgip" ] ; then
      echo $guestname.local > $guestname.hostname
      echo $vgip > $guestname.vgip
      while ! ssh $ssh_opts root@$vgip cat /dev/null ; do
	sleep 10;
	let scnt=scnt+1
	if [ $scnt -gt 6 ] ; then Die no connect ; fi
      done

      # * * * RedHat 6 Specific
      # Setting hostname so dnsmasq receives it in the dhcp request
      #
      # DoD scp $ssh_opts $guestname.hostname root@$vgip:/etc/hostname
      ssh $ssh_opts root@$vgip sed -i s/HOSTNAME=.*/HOSTNAME=$guestname.local/ /etc/sysconfig/network
      echo DHCP_HOSTNAME=$guestname.local | \
        ssh $ssh_opts root@$vgip 'cat >> /etc/sysconfig/network-scripts/ifcfg-eth0'
      # * * * End

      ssh $ssh_opts root@$vgip shutdown -r now
      # make sure our new host name has come up.
      sleep 30
      DoD grep $guestname /var/lib/libvirt/dnsmasq/default.leases > /dev/null

      break;
    else
      sleep 15
    fi
    let tcnt=tcnt+1
    if [ $tcnt -gt 5 ] ; then Die no ip ; fi
  done
}

start-libvirt-guest tbacula-fd 29
fdip=`cat tbacula-fd.vgip`
DoD scp $ssh_opts -r unittest.guest.dir root@$fdip:unittest
pushd ..
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/manifests root@$fdip:unittest/modules/bacula
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/templates root@$fdip:unittest/modules/bacula
popd
DoD ssh $ssh_opts root@$fdip bash unittest/fd.prep.bash


start-libvirt-guest tbacula-sd 28
sdip=`cat tbacula-sd.vgip`
DoD scp $ssh_opts -r unittest.guest.dir root@$sdip:unittest
pushd ..
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/manifests root@$sdip:unittest/modules/bacula
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/templates root@$sdip:unittest/modules/bacula
popd
DoD ssh $ssh_opts root@$sdip bash unittest/sd.prep.bash


start-libvirt-guest tbacula-dir 27
dirip=`cat tbacula-dir.vgip`
DoD scp $ssh_opts -r unittest.guest.dir root@$dirip:unittest
pushd ..
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/manifests root@$dirip:unittest/modules/bacula
DoD scp -i tests/tester.id -o StrictHostKeyChecking=no -r `pwd`/templates root@$dirip:unittest/modules/bacula
popd
DoD ssh $ssh_opts root@$dirip bash unittest/dir.prep.bash


# the tests
DoD ssh $ssh_opts root@$dirip bash unittest/unittest.bash

# cleanup
virsh shutdown tbacula-dir
virsh shutdown tbacula-sd
virsh shutdown tbacula-fd

# chmod 644 tester.id
echo $targs complete.
exit 0
