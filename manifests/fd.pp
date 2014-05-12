# fd.pp - 2014-02-16 07:27
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# This is installed on the client

class bacula::fd (
  $director        = 'localhost',
  $cfgdir          = '/etc/bacula',
  $piddir          = '/var/run/bacula',
  $libdir          = '/var/lib/bacula',
  $datadir         = '/srv/bacula',
  $packages        = undef,
  $max_jobs        = 2,
  $service         = 'bacula-fd',
  $fd_only         = true,
  $pgsql_support   = false,
  $pgsql_user      = undef,
  $pgsql_group     = undef,
  $mysql_support   = false,
  $user            = 'bacula',
  $group           = 'bacula',
  $manage_firewall = false,
  $template        = 'bacula/bacula-fd.conf.erb',
  ) {

  $directories = hiera('directories',{'bacula' => {
    'cfg'  => $cfgdir,
    'data' => $datadir,
    'lib'  => $libdir,
    'pid'  => $piddir,
    }}
  )
  $groups      = hiera('groups',{'bacula' => $group })
  $ports       = hiera('ports',{'bacula-sd' => '9102'})
  $servers     = hiera('servers',{'bacula-dir' => $director })
  $users       = hiera('users',{'bacula' => $user })

  $pkgs = $packages ? {
    undef      => $::osfamily ? {
      'RedHat' => ['bacula-client',],
      default  => ['bacula-fd',],
    },
    default    => $packages,
  }

  ensure_packages($pkgs)

  File {
    owner   => $users['baula'],
    group   => $groups['bacula'],
    require => Package[$pkgs],
  }

  $dircfg   = $directories['bacula']['cfg']
  $dirdata  = $directories['bacula']['data']
  $dirlib   = $directories['bacula']['lib']
  $dirscr   = "${directories['bacula']['lib']}/scripts"
  $dirpid   = $directories['bacula']['pid']
  $dirwork  = "${directories['bacula']['data']}/work"
  $dirpgsql = "${directories['bacula']['data']}/work/pgsql"
  $dirmysql = "${directories['bacula']['data']}/work/mysql"

  $dirs = [ $dircfg,
            $dirdata,
            $dirlib,
            $dirpid,
            $dirwork,
            ]

  ensure_resource('file',$dirs,{
    ensure  => 'directory',
    mode    => '0775',
    }
  )
  ensure_resource('file',"${dircfg}/bacula-fd.conf",{
    ensure  => 'file',
    mode    => '0664',
    content => template($template),
    notify  => Service[$service],
  })

  ensure_resource('service',$service,{
    ensure  => 'running',
    enable  => true,
    require => File["${dircfg}/bacula-fd.conf"],
  })

  File {
    ensure  => 'file',
    mode    => '0555',
  }

  $pg_user  = $pgsql_user ? {
    undef      => $::operatingsystem ? {
      'Darwin' => '_postgres',
      default  => 'postgres',
    },
    default    => $pgsql_user,
  }

  if $pgsql_support {
    if $pg_user {

      $pg_group  = $pgsql_group ? {
        undef      => $::operatingsystem ? {
          'Darwin' => '_postgres',
          default  => 'postgres',
        },
        default    => $pgsql_group,
      }
      ensure_resource('file',$dirscr,{
        ensure  => 'directory',
        mode    => '0775',
        }
      )
      ensure_resource('file',$dirpgsql,{
        owner   => $pg_user,
        ensure  => 'directory',
        mode    => '0775',
        }
      )
      ensure_resource('file',"${dirscr}/pgclean.bash",{
        content => template('bacula/pgclean.bash.erb'),
        require => File[$dirscr],
        }
      )
      ensure_resource('file',"${dirscr}/pgdump.bash",{
        content => template('bacula/pgdump.bash.erb'),
        require => File[$dirscr],
        }
      )
      ensure_resource('file',"${dirscr}/pglist.bash",{
        content => template('bacula/pglist.bash.erb'),
        require => File[$dirscr],
        }
      )
    } else {
      notify { "pgsql_support requires User[pg_user] for ${pg_user}" : }
    }
  }

  $my_user  = $mysql_user ? {
    undef      => $::operatingsystem ? {
      'Darwin' => '_postgres',
      default  => 'postgres',
    },
    default    => $mysql_user,
  }
  if $mysql_support {
    if $mysql_user and defined(User[$pg_user]) {

      $my_group  = $mysql_group ? {
        undef      => $::operatingsystem ? {
          'Darwin' => '_postgres',
          default  => 'postgres',
        },
        default    => $mysql_group,
      }
      ensure_resource('file',$dirscr,{
        ensure  => 'directory',
        mode    => '0775',
        }
      )
      ensure_resource('file',$dirmysql,{
        owner   => $my_user,
        ensure  => 'directory',
        mode    => '0775',
        }
      )
      ensure_resource('file',"${dirscr}/myclean.bash",{
        content => template('bacula/myclean.bash.erb'),
        require => File[$dirscr],
        }
      )
      ensure_resource('file',"${dirscr}/mydump.bash",{
        content => template('bacula/mydump.bash.erb'),
        require => File[$dirscr],
        }
      )
      ensure_resource('file',"${dirscr}/mylist.bash",{
        content => template('bacula/mylist.bash.erb'),
        require => File[$dirscr],
        }
      )
    } else {
      notify { "mysql_support requires User[my_user] for ${my_user}" : }
    }
  }
  if $manage_firewall {
    firewall { "${ports[bacula-dir]} accept - bacula-dir":
      port   => $ports['bacula-dir'],
      proto  => 'tcp',
      action => 'accept',
    }
  }
}
