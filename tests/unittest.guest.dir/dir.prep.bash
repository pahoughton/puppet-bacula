#!/bin/bash
# 2015-07-03 (cc) <paul4hough@gmail.com>
#
. unittest/prep.bash

DoD yum -y install rubygems

DoD puppet module --config unittest/pupppet.conf install puppetlabs-postgresql
DoD puppet apply --config unittest/puppet.conf unittest/dirsite.pp

exit $status
