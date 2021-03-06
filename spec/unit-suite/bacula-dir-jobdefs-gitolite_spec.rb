# bacula-dir-jobdefs-gitolite_spec.rb - 2014-03-18 04:12
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'debian',
}
os_release = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

tobject = 'bacula::dir::jobdefs::gitolite'
['Fedora','CentOS','Ubuntu',].each { |os|
  describe tobject, :type => :define do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_release[os],
      :os_maj_version         => os_release[os],
      :kernel                 => 'Linux',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      tclient = 'tester'
      let (:title) { tclient }
      #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_bacula__dir__jobdefs__gitolite(tclient) }
      it { should contain_bacula__dir__filesets__gitolite(tclient) }
      it { should contain_bacula__dir__job("gitolite-#{tclient}") }
    end
  end
}
