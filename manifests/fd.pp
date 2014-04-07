# fd.pp - 2014-02-16 07:27
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# This is installed on the client

class bacula::fd (
  $dir_host,
  $configdir     = '/etc/bacula',
  $piddir        = '/var/run/bacula',
  $libdir        = '/var/lib/bacula',
  $datadir       = '/srv/bacula',
  $fd_packages   = undef,
  $max_jobs      = 2,
  $service       = 'bacula-fd',
  $fd_only       = true,
  $pgres_support = true,
  $pgres_user    = undef,
  $pgres_group   = undef,
  $mysql_support = true,
  $user          = 'bacula',
  $group         = 'bacula',
  $template      = 'bacula/bacula-fd.conf.erb',
  ) {

  $packages = $fd_packages ? {
    undef   => $::osfamily ? {
      'debian' => 'bacula-fd',
      'RedHat' => 'bacula-client',
      default  => undef,
    },
    default => $fd_packages,
  }

  package { $packages :
    ensure => 'installed',
  }

  $workdir       = "${datadir}/work"

  File {
    owner   => $user,
    group   => $group,
    require => Package[$packages],
  }

  if $fd_only {
    file { $datadir :
      ensure  => 'directory',
      mode    => '0755',
    }
    ->
    file { [$configdir,
            $piddir,
            $workdir,
            $libdir,
            "${libdir}/scripts",] :
      ensure  => 'directory',
      mode    => '0755',
    }
  }
  file { "${configdir}/bacula-fd.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$service],
    require => Package[$packages],
  }
  service { $service :
    ensure  => 'running',
    enable  => true,
    require => File["${configdir}/bacula-fd.conf"],
  }

  if $pgres_support {
    $pg_user  = $pgres_user ? {
      undef      => $::operatingsystem ? {
        'Darwin' => '_postgres',
        default  => 'postgres',
      },
      default    => $pgres_user,
    }
    $pg_group  = $pgres_group ? {
      undef      => $::operatingsystem ? {
        'Darwin' => '_postgres',
        default  => 'postgres',
      },
      default    => $pgres_group,
    }
    $pg_dumpdir = "${workdir}/postgres"
    file { [$pg_dumpdir, "${pg_dumpdir}/fifo"] :
      ensure  => 'directory',
      owner   => $pg_user,
      group   => $pg_group,
      mode    => '0775',
    }
    file { "${libdir}/scripts/pgdump.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/pgdump.bash.erb'),
      require => File["${libdir}/scripts"],
    }
    file { "${libdir}/scripts/pgclean.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/pgclean.bash.erb'),
      require => File["${libdir}/scripts"],
    }
    file { "${libdir}/scripts/pglist.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/pglist.bash.erb'),
      require => File["${libdir}/scripts"],
    }
  }
  if $mysql_support {
    $my_dumpdir = "${workdir}/mysql"
    file { [$my_dumpdir, "${my_dumpdir}/fifo"] :
      ensure  => 'directory',
      mode    => '0775',
    }
    file { "${libdir}/scripts/mydump.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/mydump.bash.erb'),
      require => File["${libdir}/scripts"],
    }
    file { "${libdir}/scripts/myclean.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/myclean.bash.erb'),
      require => File["${libdir}/scripts"],
    }
    file { "${libdir}/scripts/mylist.bash" :
      ensure  => 'file',
      mode    => '0555',
      content => template('bacula/mylist.bash.erb'),
      require => File["${libdir}/scripts"],
    }
  }
}
