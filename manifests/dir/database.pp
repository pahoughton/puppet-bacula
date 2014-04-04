# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# fixme - need to be able to provide existing db
#
class bacula::dir::database (
  $srv_pass,
  $host     = 'localhost',
  $backend  = 'postgresql',
  $user     = 'bacula',
  $pass     = 'bacula',
) {

  $make_db_tables_command = $::operatingsystem ? {
    'CentOS'  => "/usr/libexec/bacula/make_${backend}_tables ${db_params}",
    default   => "/usr/libexec/bacula/make_bacula_tables ${backend} ${db_params}",
  }

  case $backend {
    'postgresql' : {

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
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }

  $db_params = $backend ? {
    'sqlite'      => '',
    'mysql'       => "--user=${user} --password=${pass}",
    'postgresql'  => '',
  }
  $make_db_tables_user = $backend ? {
    'postgresql' => $user,
    default      => root,
  }
  exec { $make_db_tables_command :
    command     => $make_db_tables_command,
    user        => $make_db_tables_user,
    notify      => Service[$bacula::dir::service],
    refreshonly => true,
  }
}
