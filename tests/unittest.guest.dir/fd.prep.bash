#!/bin/bash
# 2015-07-03 (cc) <paul4hough@gmail.com>
#
. unittest/prep.bash

DoD puppet apply --config unittest/puppet.conf unittest/fdsite.pp

exit $status
