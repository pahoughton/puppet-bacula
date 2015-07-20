# 2015-07-20 (cc) <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::dir::storage'

supported = {
  'RedHat' => {
    'RedHat' => ['6','7'],
    'CentOS' => ['6','7'],
    }
}

title = 'bacnodename'
cfgdir = '/etc/bacula'

supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :define do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
        }
        let (:facts) {tfacts}
        let (:title) {title}
        context "supports facts #{tfacts}" do
          it { should contain_bacula__dir__storage(title) }
          it { should contain_file("#{cfgdir}/dir.d/storage-#{title}.conf").
            with_content(/bacsdpass/)
          }
        end
      end
    }
  }
}
