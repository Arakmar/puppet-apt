class apt::proxy_client(
  $proxy = 'http://localhost',
  $port = '3142',
  $ensure = present
){

  apt_conf { '20proxy':
    content => template('apt/20proxy.erb'),
    ensure => $ensure
  }
}
