# bacula-dir-filesets-gitolite_spec.rb - 2014-03-17 16:46
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

tobject = 'bacula::dir::filesets::gitolite'
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
      let (:title) { 'test' }
     #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_bacula__dir__filesets__gitolite('test') }
      it { should contain_bacula__dir__fileset('gitolite-test') }
    end
  end
}
