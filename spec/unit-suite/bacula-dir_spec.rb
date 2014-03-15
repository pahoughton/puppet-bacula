# bacula-dir_spec.rb - 2014-03-15 08:42
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# database args validated by database class tests
#
require 'spec_helper'

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'bacula::dir', :type => :class do
    context "supports operating system #{os}" do
      let(:facts) do {
          :osfamily  => $os_family[os],
          :operatingsystem => os,
          :hostname => 'testdirhost',
      } end

      context 'default params' do
        it { should contain_class('bacula::dir') }

        ['/etc/bacula',
         '/srv/bacula',
         '/srv/bacula/work',
         '/srv/bacula/backups',
         '/srv/bacula/restore',].each { |dir|
          it { should contain_file(dir).
            with( 'ensure' => 'directroy',
                  'mode'   => '0750' )
          }

        }
      end
      params = {
        'configdir' => '/etc-test/bacula',
        'rundir'    => '/var-test/run/bacula',
      }
      libdir='/var-test/lib/bacula'
      workdir='/srv-test/bacula/work'
      backupdir='/srv-test/bacula/backups'
      restoredir='/srv-test/bacula/restore'
      context "with params #{p} => #{params[p]}" do
        it { should contain_file(dir).
          with( 'ensure' => 'directroy',
                'mode'   => '0750' )
        }
      end
    end
  end
}
