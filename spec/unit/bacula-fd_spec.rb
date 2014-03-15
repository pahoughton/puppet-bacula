require 'spec_helper'

describe 'bacula::fd', :type => :class do
  describe 'Fedora 20' do 
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'Fedora',
        :operatingsystemrelease => '20',
        :hostname => 'bachost',
      }
    end
    
    describe 'with parameters' do
      let :params do
        {
          :dir_host => 'bacdir',
        }
      end
      
      it 'should create config file' do
        should contain_file("/etc/bacula/bacula-fd.conf").with({
          :ensure => 'file',
        })
      end
    end
  end
  describe 'CentOS' do 
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.0',
        :hostname => 'bachost',
      }
    end
    
    describe 'with parameters' do
      let :params do
        {
          :dir_host => 'bacdir',
        }
      end
      
      it 'should create config file' do
        should contain_file("/etc/bacula/bacula-fd.conf").with({
          :ensure => 'file',
        })
      end
    end
  end
end
