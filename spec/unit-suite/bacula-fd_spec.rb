# bacula-fd_spec.rb - 2014-02-16 17:23
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::fd'
ttype   = :class

packages = {
  'undef' => {
    'undef' => {
      'undef' => ['bacula-fd'],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => ['bacula-fd'],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => ['bacula-client'],
    },
  },
}
services = {
  'undef' => {
    'undef' => {
      'undef' => ['bacula-fd'],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => [],
    },
  },
}
files = {
  'undef' => {
    'undef' => {
      'undef' => ['/etc/bacula',
                  '/etc/bacula/bacula-fd.conf',
                  '/srv/bacula/work',
                  '/var/run/bacula',
                  '/var/lib/bacula',
                  # todo need a way to have pg/my users defined
                  # '/var/lib/bacula/scripts',
                  # '/srv/bacula/work/mysql',
                  # '/srv/bacula/work/pgsql',
                  # '/var/lib/bacula/scripts/myclean.bash',
                  # '/var/lib/bacula/scripts/mydump.bash',
                  # '/var/lib/bacula/scripts/mylist.bash',
                  # '/var/lib/bacula/scripts/pgclean.bash',
                  # '/var/lib/bacula/scripts/pgdump.bash',
                  # '/var/lib/bacula/scripts/pglist.bash',
                 ],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => [],
    },
  },
}

supported = {
  'undef'  => { 'undef' => ['undef' ],
  },
  'Debian' => { 'undef' => ['undef',
                           ],
  },
  'RedHat' => { 'undef' => ['undef',
                           ],
  },
}
supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => ttype do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          files[fam][os][rel].each { |fn|
            it { should contain_file(fn) }
          }
          services[fam][os][rel].each { |svc|
            it { should contain_service(svc) }
          }
        end
      end
    }
  }
}
