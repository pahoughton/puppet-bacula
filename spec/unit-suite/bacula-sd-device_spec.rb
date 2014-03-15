# bacula-sd-device_spec.rb - 2014-03-15 10:13
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

describe 'bacula::sd::device', :type => :define do
  $param_list = [
                ]
  context "supports all operating systems" do
    configdir='/etc/bacula'
    title='Default'
    let (:title) {title}
    context "default params" do
      it { should contain_bacula__sd__device(title) }
      it { should contain_file("#{configdir}/sd.d/device-#{title}.conf").
        with_ensure('file').
        with_content(/#{title}/)
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
