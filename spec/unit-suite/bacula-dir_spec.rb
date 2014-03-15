# bacula-dir_spec.rb - 2014-03-15 08:42
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# database args validated by database class tests
#
require 'spec_helper'

# describe 'bacula director server deployment' do
  $os_rel = {
    'Fedora' => '20',
    'CentOS' => '6.',
    'Ubuntu' => '13.10',
  }
  $os_family = {
    'Fedora' => 'RedHat',
    'CentOS' => 'RedHat',
    'Ubuntu' => 'Debian',
  }

  ['Fedora','CentOS','Ubuntu'].each { |os|
    describe 'bacula::dir', :type => :class do
      context "supports operating system #{os}" do
        let(:facts) do {
            :osfamily               => $os_family[os],
            :operatingsystem        => os,
            :operatingsystemrelease => $os_rel[os],
            :concat_basedir         => 'fixmefor-postgresql',
            :hostname               => 'testdirhost',
          } end

        context 'default params' do
          it { should contain_class('bacula::dir') }

          ['/etc/bacula',
           '/srv/bacula',
           '/srv/bacula/work',
           '/srv/bacula/restore',].each { |dir|
            it { should contain_file(dir).
              with( 'ensure' => 'directory',
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
        params.each { |p,val|
          context "with params #{p} => #{val}" do
            let :params do {
                p => val,
              } end
            it { should contain_file(val).
              with( 'ensure' => 'directory',
                    'mode'   => '0750' )
            }
          end
        }
      end
    end
  }
# end
