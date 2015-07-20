# 2015-07-19 (cc) <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::dir::node'

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
      describe tobject, :type => :define do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
        }
        title = 'bacnode'
        let (:facts) {tfacts}
        let (:title) {title}

        context "supports facts #{tfacts} title #{title}" do
          it { should contain_bacula__dir__node(title) }
          #it { should contain_file("/etc/bacula/dir.d/node-#{title}.conf") }
        end
      end
    }
  }
}
