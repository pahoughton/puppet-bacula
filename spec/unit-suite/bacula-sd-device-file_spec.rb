# bacula-sd-device-file_spec.rb - 2014-05-12 11:34
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# bacula-sd-device_spec.rb - 2014-03-15 10:13
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

describe 'bacula::sd::device::file', :type => :define do
  $param_list = [
                ]
  context "supports all operating systems" do
    configdir='/etc/bacula'
    title='Default'
    let (:title) {title}
    tparams = {
      'device' => '/srv/backup',
    }
    context "param #{tparams}'" do
      let :params do tparams end
      it { should contain_file(tparams['device']).
        with_ensure('directory')
      }
    end
    tparamval='test Param value'
    $param_list.each { |p|
      context "param #{p} => '#{tparamval}'" do
        let :params do {
            p => tparamval
          } end
        it { should contain_file("#{configdir}/sd.d/device-#{title}.conf").
          with_ensure('file').
          with_content(/#{tparamval}/)
        }
      end
    }
  end
end
