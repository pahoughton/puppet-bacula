# bacula-fd_spec.rb - 2014-02-16 17:23
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
['Fedora','CentOS','Ubuntu'].each { |os|

  describe 'bacula::fd', :type => :class do
    context "supports operating system #{os}" do
      let(:facts) do {
          :osfamily  => $os_family[os],
          :operatingsystem => os,
          :hostname => 'testhost',
      } end

      dirhost='bactestdir'
      context "with dir_host => #{dirhost}" do
        let :params do {
          :dir_host => 'bacdir',
        } end

        it { should contain_file("/etc/bacula/bacula-fd.conf").
          with({ 'ensure' => 'file',
               'content' => /dirhost/, })
        }
        it { should contain_service('bacula-fd').
          with({ 'ensure' => 'running',
                 'enable' => true, })
        }
      end
    end
  end
}
