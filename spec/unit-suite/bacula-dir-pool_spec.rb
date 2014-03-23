# bacula-dir-pool_spec.rb - 2014-03-15 09:32
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

describe 'bacula::dir::pool', :type => :define do
  $param_list = ['storage',
                 'use_once',
                 'max_vol_jobs',
                 'max_vol_files',
                 'max_vol_bytes',
                 'vol_use_dur',
                 'catalog_files',
                 'auto_prune',
                 'vol_retent',
                 'scratch_pool',
                 'recycle_pool',
                 'recycle',
                 'recycle_oldest',
                 'recycle_current',
                 'purge_oldest',
                 'cleaning_prefix',
                 'label_format'
                ]
  context "supports all operating systems" do
    configdir='/etc/bacula'
    title='Default'
    let (:title) {title}
    context "default params" do
      it { should contain_bacula__dir__pool(title) }
      it { should contain_file("#{configdir}/dir.d/pool-#{title}.conf").
        with_ensure('file').
        with_content(/#{title}/)
      }
    end
    tparamval='test Param value'
    $param_list.each { |p|
      let :params do {
          p => tparamval
        } end
      it { should contain_file("#{configdir}/dir.d/pool-#{title}.conf").
        with_ensure('file').
        with_content(/#{tparamval}/)
      }
    }
  end
end
