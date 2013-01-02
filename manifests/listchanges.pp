class apt::listchanges {

  if $apt_listchanges_version == '' {
    $apt_listchanges_version = 'present'
  }

  if $apt_listchanges_config == '' {
    $apt_listchanges_config = "apt/${::operatingsystem}/listchanges_${::lsbdistcodename}.erb"
  }

  if $apt_listchanges_frontend == '' {
    $apt_listchanges_frontend = 'mail'
  }

  if $apt_listchanges_email == '' {
    $apt_listchanges_email = 'root'
  }

  if $apt_listchanges_confirm == '' {
    $apt_listchanges_confirm = '0'
  }

  if $apt_listchanges_saveseen == '' {
    $apt_listchanges_saveseen = '/var/lib/apt/listchanges.db'
  }

  if $apt_listchanges_which == '' {
    $apt_listchanges_which = 'both'
  }

  package { 'apt-listchanges': ensure => $apt_listchanges_ensure_version }

  file { '/etc/apt/listchanges.conf':
    content => template($apt_listchanges_config),
    mode    => '0644', owner => root, group => root,
    require => Package['apt-listchanges'];
  }
}
