# database.pp - 2014-02-15 14:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class bacula::database (
  $srv_pass = undef,
  $backend  = 'postgresql',
  $user     = 'bacula',
  $pass     = 'bacula',
) {

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
    command     => $::operatingsystem ? {
      'CentOS'  => "/usr/libexec/bacula/make_${backend}_tables ${db_params}",
      default   => "/usr/libexec/bacula/make_bacula_tables ${backend} ${db_params}",
    },
    user        => $backend ? {
      'postgresql' => $user,
      default      => root,
    },
    notify      => Service[$bacula::dir::service],
    refreshonly => true,
  }
}
