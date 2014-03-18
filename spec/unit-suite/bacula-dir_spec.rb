# bacula-dir_spec.rb - 2014-03-15 08:42
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# database args validated by database class tests
#
require 'spec_helper'

os_service = {
  'Fedora' => 'bacula-dir',
  'CentOS' => 'bacula-dir',
  'Ubuntu' => 'bacula-director',
}
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

tobject = 'bacula::dir'
['Fedora','CentOS','Ubuntu'].each { |os|
  confdir = '/etc/bacula'
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      :kernel                 => 'Linux',
      :concat_basedir         => '4postgresql',
      :hostname               => 'tester',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
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
        it { should contain_file("#{confdir}/bacula-dir.conf") }
        it { should contain_file("#{confdir}/dir.d") }
        it { should contain_service(os_service[os]) }
        it { should contain_bacula__dir__job('Restore') }
        it { should contain_bacula__dir__job('Default') }
        it { should contain_bacula__dir__pool('Default') }
        it { should contain_bacula__dir__fileset('FullSet') }
        it { should contain_bacula__dir__jobdefs__postgresql('tester') }
      end
      params = {
        'configdir'  => '/etc-test/bacula',
        'rundir'     => '/var-test/run/bacula',
        'libdir'     => '/var-test/lib/bacula',
        'workdir'    => '/srv-test/bacula/work',
        'restoredir' => '/srv-test/bacula/restore'
      }
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
