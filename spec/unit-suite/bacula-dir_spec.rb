# 2014-03-15 (cc) paul4hough@gmail.com
#
require 'spec_helper'

tobject = 'bacula::dir'

supported = {
  'RedHat' => {
    'RedHat' => ['6.5','6.6','7.0'],
    'CentOS' => ['6.5','6.6','7.0'],
    }
}
ospkgs = {
  'RedHat' => "bacula-director",
  'CentOS' => 'bacula-director',
}
ossvc = {
  'RedHat' => 'bacula-dir',
  'CentOS' => 'bacula-dir',
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
