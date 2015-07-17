# 2015-07-13 (cc) <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::dir::client'

supported = {
  'RedHat' => {
    'RedHat' => ['6','7'],
    'CentOS' => ['6','7'],
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
          it { should contain_bacula__dir__client(title) }
          #it { should contain_file("#{cfgdir}/dir.d/client-test.conf") }
          # ['file_ret',
          #  'job_ret',
          #  'auto_prune',
          #  'max_jobs',
          #  'password',
          # ].each { |p|
          #   let :params do { p => 'test-param-val' } end
          #   it { should contain_file("#{cfgdir}/dir.d/client-#{title}.conf").
          #     with_content(/test-param-val/)
          #   }
          # }
        end
      end
    }
  }
}
