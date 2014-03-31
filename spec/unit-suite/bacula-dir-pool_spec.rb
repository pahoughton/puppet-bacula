# bacula-dir-pool_spec.rb - 2014-03-15 09:32
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

param_list = ['storage',
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
              'label_format',
             ]

bacula = {
  'storage'          => 'Storage',
  'use_once'         => 'Use Volume Once',
  'max_vol_jobs'     => 'Maximum Volume Jobs',
  'max_vol_files'    => 'Maximum Volume Files',
  'max_vol_bytes'    => 'Maximum Volume Bytes',
  'vol_use_dur'      => 'Volume Use Duration',
  'catalog_files'    => 'Catalog Files',
  'auto_prune'       => 'Auto Prune',
  'vol_retent'       => 'Volume Retention',
  'scratch_pool'     => 'ScratchPool',
  'recycle_pool'     => 'RecyclePool',
  'recycle'          => 'Recycle',
  'recycle_oldest'   => 'Recycle Oldest Volume',
  'recycle_current'  => 'Recycle Current Volume',
  'purge_oldest'     => 'Purge Oldest',
  'cleaning_prefix'  => 'Cleaning Prefix',
  'label_format'     => 'Label Format',
}

tobject = 'bacula::dir::pool'
describe tobject, :type => :define do
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
  # fixme
  # tparamval='test Param value'
  # param_list.each { |p|
  #   let :params do {
  #       p => tparamval
  #     } end
  #   it { should contain_file("#{configdir}/dir.d/pool-#{title}.conf").
  #     with( 'content' => /#{bacula[p]}.*#{tparamval}/, )
  #   }
  # }
end
