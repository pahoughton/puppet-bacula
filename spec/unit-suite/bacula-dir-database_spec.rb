# bacula-dir-database_spec.rb - 2014-03-15 10:49
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_lsbdist = {
  'Ubuntu' => 'ubuntu',
}
os_lsbname = {
  'Ubuntu' => 'precise',
}

os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'debian',
}
os_rel = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

tobject = 'bacula::dir::database'
# fixme 'CentOS','Ubuntu'
['Fedora',].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      :hostname               => 'testdbhost',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      tparams = {
        :name     => 'bacula',
        :srv_pass => 'psql',
      }
      context "params #{tparams}" do
        let :params do tparams end
        it { should contain_class(tobject) }
        it { should contain_postgresql__server__db('bacula') }
        it { should contain_exec('/usr/libexec/bacula/make_bacula_tables postgresql ') }
      end
    end
  end
}
