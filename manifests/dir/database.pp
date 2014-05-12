# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# fixme - need to be able to provide existing db
#
class bacula::dir::database (
  $srv_pass,
  $host     = 'localhost',
  $backend  = 'pgsql',
  $user     = 'bacula',
  $pass     = 'bacula',
) {

  case $backend {
    'pgsql' : {
      $mbkend = 'postgresql'
      $muser  = 'postgres'
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }

  $make_db_tables_command = $::operatingsystem ? {
    'Ubuntu'  => "/usr/share/bacula-director/make_${mbkend}_tables -U ${user} -h ${host}",
    default   => "/usr/libexec/bacula/make_${mbkend}_tables -U ${user} -h ${host}",
  }

  case $backend {
    'pgsql' : {

      if ! $postgresql::server::postgres_password and $srv_pass {
        class { 'postgresql::server' :
          postgres_password  => $srv_pass,
          listen_addresses   => '*',
        }
      }
      postgresql::server::db { $name :
        owner    => $user,
        user     => $user,
        password => $pass,
        notify   => Exec[$make_db_tables_command],
      }
      # fixme - hardcoded until find a good way to get ~$user dir
      $pghome = $::osfamily ? {
        'Debian' => '/var/lib/postgresql',
        'RedHat' => '/var/lib/pgsql',
      }
      concat { "${pghome}/.pgpass" :
        owner   => $postgresql::server::user,
        group   => $postgresql::server::group,
        mode    => '0600',
        require => Postgresql::Server::Db[$name],
      }
      concat::fragment { 'bacula' :
        target  => "${pghome}/.pgpass",
        content => "${host}:*:*:${user}:${pass}\n",
      }
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }

  # todo require pgsql depended
  exec { $make_db_tables_command :
    command     => $make_db_tables_command,
    environment => "db_name=${name}",
    user        => $muser,
    notify      => Service[$bacula::dir::service],
    require     => Concat["${pghome}/.pgpass"],
    refreshonly => true,
  }
}
