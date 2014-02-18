# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::database (
  $backend  = 'postgresql',
  $srv_pass = 'psql',
  $user     = 'bacula',
  $pass     = 'bacula',
) {

  case $backend {
    'postgresql' : {
      class { 'postgresql::server' :
        postgres_password  => $srv_pass,
        listen_addresses   => '*',
      }
      postgresql::server::db { $name :
        owner    => $user,
        user     => $user,
        password => $pass,
        require  => Class['postgresql::server'],
        notify   => Exec['make_db_tables'],
      }
    }
    default : {
      fail("unsupported db backend: ${backend}")
    }
  }
  
  $db_params = $backend ? {
    'sqlite'      => '',
    'mysql'       => "--user=${user} --password=${passw}",
    'postgresql'  => "",
  }
  exec { 'make_db_tables':
    command     => "/usr/libexec/bacula/make_bacula_tables ${backend} ${db_params}",
    user        => $backend ? {
      'postgresql' => $user,
      default      => root,
    },
    refreshonly => true,
  }
}
