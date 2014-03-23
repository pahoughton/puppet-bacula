bacula
======

Complete configuration of bacula with some application specific jobs

  # director node
  $servers = hiera('servers')
  $passwords = hiera('passwords')
  $emails = hiera('email')

  class { 'bacula::dir' :
    db_backend => 'postgresql',
    db_pass    => $passwords['postgres-bacula'],
    sd_host    => $servers['bacula-sd'],
    mail_to    => $emails['bacula-dir'],
    require    => Class['postgresql::server'],
  }

  bacula::dir::client{ 'host.me.org' }
  bacula::dir::jobdefs::gitolite { 'host.me.org' :
  bacula::dir::jobdefs::mysql { 'host.me.org' : }
  bacula::dir::jobdefs::postgresql { 'host.me.org' : }

  # storage node
  class { 'bacula::sd' :
    dir_host   => 'your-bac-dir.me.org',
    auto_label => true,
  }
  # client node
  class { 'bacula::fd' :
    dir_host => 'your-bac-dir.me.org',
  }

  please see source and tests for now.

Table of Contents
-----------------
[Overview](#overview)

Overview
--------
Manage bacula
