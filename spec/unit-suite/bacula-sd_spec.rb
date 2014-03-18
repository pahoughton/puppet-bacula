# sd_spec.rb - 2014-02-17 03:52
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_rel = {
  'Fedora' => '20',
  'CentOS' => '6.',
  'Ubuntu' => '13.10',
}
os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'Debian',
}
tobject = 'bacula::sd'
['Fedora','CentOS','Ubuntu'].each { |os|
  confdir = '/etc/bacula'
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      :kernel                 => 'Linux',
      :hostname               => 'tester',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      dirhost='bactestdir'
      context "with dir_host => #{dirhost}" do
        let :params do {
            :dir_host => dirhost,
          } end

        it { should contain_file("#{confdir}/bacula-sd.conf").
          with_ensure('file').
          with_content(/#{dirhost}/)
        }
        it { should contain_service('bacula-sd').
          with({ 'ensure' => 'running',
                 'enable' => true, })
        }
        it { should contain_file("#{confdir}/sd.d") }
        it { should contain_bacula__sd__device__file('Backupdir') }
      end
    end
  end
}
