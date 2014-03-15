# sd_spec.rb - 2014-02-17 03:52
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

  describe 'bacula::sd', :type => :class do
    context "supports operating system #{os}" do
      let(:facts) do {
          :osfamily  => $os_family[os],
          :operatingsystem => os,
          :hostname => 'testhost',
      } end

      dirhost='bactestdir'
      context "with dir_host => #{dirhost}" do
        let :params do {
          :dir_host => dirhost,
        } end

        it { should contain_file("/etc/bacula/bacula-sd.conf").
          with_ensure('file').
          with_content(/#{dirhost}/)
        }
        it { should contain_service('bacula-sd').
          with({ 'ensure' => 'running',
                 'enable' => true, })
        }
      end
    end
  end
}
