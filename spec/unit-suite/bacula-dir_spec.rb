# bacula-dir_spec.rb - 2014-03-15 08:42
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# database args validated by database class tests
#
require 'spec_helper'

tobject = 'bacula::dir'

supported = {
  'RedHat' => {
    'Fedora' => ['20','21'],
    'RedHat' => ['6','7'],
    }
}
lsbname = {
  'RedHat' => {
    'RedHat' => {
      '6' => '6',
      '7' => '7',
    },
    'Fedora' => {
      '20' => '20',
      '21' => '21',
    },
  }
}

ospkgs = {
  'RedHat' => "bacula-director-postgresql",
  'Fedora' => 'bacula-director',
}
ossvc = {
  'RedHat' => 'bacula-dir',
  'Fedora' => 'bacula-dir',
}

supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :class do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
          :lsbdistcodename        => lsbname[fam][os][rel],
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          it { should contain_class(tobject) }
          it { should contain_package(ospkgs[os]) }
          it { should contain_service(ossvc[os]) }
        end
      end
    }
  }
}
