
puppet-bacula
=============

(Features - test output)[fixme]

Complete configuration of bacula with some application specific jobs
```
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
  bacula::dir::jobdefs::gitolite { 'host.me.org' : }
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
```

Table of Contents
-----------------
[Overview](#overview)
[Contribute](#contribute)
[License](#license)

Overview
--------
Manage bacula

Contribute
----------
[Github pahoughton/puppet-bacula](https://github.com/pahoughton/puppet-bacula)

License
--------
Copyright (CC) 2014 Paul Houghton <paul4hough@gmail.com>

[![LICENSE](http://i.creativecommons.org/l/by/3.0/88x31.png)](http://creativecommons.org/licenses/by/3.0/)

[![endorse](https://api.coderwall.com/pahoughton/endorsecount.png)](https://coderwall.com/pahoughton)
