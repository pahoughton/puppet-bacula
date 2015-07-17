# 2015-07-14 (cc) <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::bconsole'

supported = {
  'RedHat' => {
    'RedHat' => ['6','7'],
    'CentOS' => ['6','7'],
    }
}

cfgdir = '/etc/bacula'


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
        }
        let (:facts) {tfacts}
        context "supports facts #{tfacts}" do
          it { should contain_class(tobject) }
          it { should contain_package('bacula-console') }
          it { should contain_file("#{cfgdir}/bconsole.conf") }
        end
      end
    }
  }
}
