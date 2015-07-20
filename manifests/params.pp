# 2015-07-01 (cc) <paul4hough@gmail.com>
#
class bacula::params (
  $dirname      = 'bacula-dir', # bacula director name
  $dirpass      = 'bacula-dir-pass',
  $configdir    = '/etc/bacula',
  $libdir       = '/var/lib/bacula',
  $workdir      = '/var/lib/bacula/work',
  $restoredir   = '/var/tmp',
  $user         = 'bacula',
  $group        = 'bacula',
  $max_jobs     = 5,
  $mail_to      = 'root@localhost',
  $catalogname  = 'BacCatalog',
  $dbbackend    = 'pgsql',
  $dbhost       = 'localhost',
  $dbname       = 'bacula',
  $dbuser       = 'bacula',
  $dbpass       = 'bacula',
  $jobmesgs     = 'JobMesgs',
  $fdpass       = "bacula-fd-pass",
  $sdaddr       = 'bacula-sd',
#  $sdpass       = 'sdpass', - fixme not working w/ hiera
  ) {
  case $::operatingsystem {
    'Fedora','RedHat' : {
      $dirpkgs   = ['bacula-director']
      $dirsvc    = 'bacula-dir'
    }
    'CentOS' : {
      $dirpkgs   = ["bacula-director"]
      $dirsvc    = 'bacula-dir'
    }
    'Ubuntu' : {
      case $db_backend {
        'postgresql' : {
          $dirpkgs   = ['bacula-director']
        }
        default : {
          $dirpkgs   = ['bacula-common-pgsql','bacula-director-pgsql']
        }
      }
      $dirsvc    = 'bacula-director'
    }
    default : {
      fail("unsupported operatingsystem '$::operatingsystem'")
    }
  }
}
