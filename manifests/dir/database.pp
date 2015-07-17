# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::dir::database (
  $backend     = $::bacula::params::dbbackend,
  $install_srv = $::bacula::params::install_dbsrv,
  $srv_pass    = $::bacula::params::dbrv_pass,
  $host        = $::bacula::params::dbhost,
  $dbname      = $::bacula::params::dbname,
  $user        = $::bacula::params::dbuser,
  $pass        = $::bacula::params::dbpass,
) {


  case $backend {
    'pgsql' : {
      $make_db_tables_command = "/usr/libexec/bacula/make_postgresql_tables"
      class { 'postgresql::server' :
        listen_addresses           => '*',
      }
      postgresql::server::db { $dbname :
        owner    => $user,
        user     => $user,
        password => postgresql_password($user, $pass),
        require  => Class['postgresql::server'],
        notify   => Exec[$make_db_tables_command],
      }
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }

  $make_db_tables_user = $backend ? {
    'pgsql'  => $user,
    default  => root,
  }
  exec { $make_db_tables_command :
    command     => $make_db_tables_command,
    user        => $make_db_tables_user,
    notify      => Service[$bacula::dir::service],
    refreshonly => true,
  }
}
