# bacula-dir-database_spec.rb - 2014-03-15 10:49
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'
$os_rel = {
  'Fedora' => 20,
  'CentOS' => '6.',
  'Ubuntu' => '13.10',
}
$os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'Debian',
}
['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'bacula::dir::database', :type => :class do
    context "supports operating system #{os}" do
      let(:facts) do {
          :osfamily               => $os_family[os],
          :operatingsystem        => os,
          :operatingsystemrelease => $os_rel[os],
          :hostname               => 'testdbhost',
      } end
      context "required param srv_pass => 'psql'" do
        let :params do {
            :srv_pass => 'psql',
        } end

        # it { should contain_class('bacula::dir::database') }
        # it { should contain_postgresql__server__db('bacula') }
        # it { should contain_exec('bacula-make-db-tables').
        #   with_notify('Service[bacula]')
        # }
        # it { should contain_file("#{configdir}/sd.d/device-#{title}.conf").
        #   with_ensure('file').
        #   with_content(/#{tparamval}/)
        # }
      end
    end
  end
}
