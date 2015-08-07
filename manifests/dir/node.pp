# 2015-07-19 (cc) <paul4hough@gmail.com>

define bacula::dir::node (
  $configdir      = $::bacula::params::configdir,
  $file_ret       = '60 days',
  $job_ret        = '60 days',
  $auto_prune     = 'yes',
  $max_jobs       = '5',
  $password       = $::bacula::params::fdpass,
  $catalogname    = $::bacula::params::catalogname,
  $ignore_changes = undef,
  $enable_vss     = undef,
  $incdirs        = ['/etc','/home'],
  $incopts        = ['compression = GZIP9','signature = MD5',],
  $options        = undef,
  $excdirs        = ['/etc/bacula',],
  $template       = 'bacula/node.conf.erb',
  ) {

  include ::bacula::params

  $fdname = $name ? {
    undef   => $title,
    default => $name,
  }

  file { "${configdir}/dir.d/node-${fdname}.conf" :
    ensure  => 'file',
    content => template($template),
    notify  => Service[$bacula::dir::service],
    require => [File["${configdir}/dir.d/"],
                Class[bacula::params]
                ]
  }
}
