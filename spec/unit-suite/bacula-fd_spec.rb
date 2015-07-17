# bacula-fd_spec.rb - 2014-02-16 17:23
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$os_family = {
  'RedHat' => 'redhat',
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
$pkgs = {
  'redhat' => 'bacula-client',
  'debian' => 'bacula-fd',
}

['RedHat','Fedora','CentOS','Ubuntu'].each { |os|
  describe 'bacula::fd', :type => :class do
    context "supports operating system #{os}" do
      let(:facts) do {
          :osfamily  => $os_family[os],
          :operatingsystem => os,
          :hostname => 'testhost',
      } end

      configdir='/etc/bacula'
      dirhost='bactestdir'
      context "with dir_host => #{dirhost}" do
        let :params do {
          :dirname => "#{dirhost}-dir",
        } end

        it { should contain_package($pkgs[$os_family[os]]) }
        it { should contain_file("#{configdir}/bacula-fd.conf").
          with_ensure('file').
          with_content(/#{dirhost}/).
          with_content(/bacula-fd-pass/)
        }
        it { should contain_service('bacula-fd').
          with({ 'ensure' => 'running',
                 'enable' => true, })
        }
      end
    end
  end
}
