#!/bin/bash
# 2015-06-22 (cc) <paul4hough@gmail.com>
#

. unittest/prep.bash

DoD puppet apply --config unittest/puppet.conf unittest/sdsite.pp

exit $status
