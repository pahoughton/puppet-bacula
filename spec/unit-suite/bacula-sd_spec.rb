# sd_spec.rb - 2014-02-17 03:52
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'bacula::sd'

os_rel = {
  'RedHat' => '6.',
  'Fedora' => '20',
  'CentOS' => '6.',
  'Ubuntu' => '13.10',
}
os_family = {
  'RedHat' => 'RedHat',
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'Debian',
}

confdir = '/etc/bacula'
workdir = '/var/lib/bacula/work'

['RedHat','Fedora','CentOS','Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      :kernel                 => 'Linux',
      :hostname               => 'bactsthost',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      dirname='bactestdir'
      context "with dirname => #{dirname}" do
        let :params do {
            :dirname => dirname,
          } end

        it { should contain_file("#{confdir}/bacula-sd.conf").
          with_ensure('file').
          with_owner('bacula').
          with_content(/#{dirname}/).
          with_content(/bacsdpass/).
          with_content(/Name *= *.bactsthost/)
        }
        it { should contain_file("#{workdir}").
          with_ensure('directory').
          with_owner('bacula')
        }
        it { should contain_service('bacula-sd').
          with({ 'ensure' => 'running',
                 'enable' => true, })
        }
        it { should contain_file("#{confdir}/sd.d") }
        it { should contain_bacula__sd__device__file('sd-default-backupdir') }
      end
    end
  end
}
