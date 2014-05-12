# bacula-dir-filesets-pgsql_spec.rb - 2014-03-18 04:01
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

tobject = 'bacula::dir::filesets::pgsql'
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
      let (:title) { 'tester' }
      #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_bacula__dir__filesets__pgsql('tester') }
      it { should contain_bacula__dir__fileset('pgsql-tester') }
    end
  end
}
