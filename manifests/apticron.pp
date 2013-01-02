class apt::apticron {

  if $apticron_ensure_version == '' {
    $apticron_ensure_version = 'present'
  }

  if $apticron_config == '' {
    $apticron_config = "apt/${::operatingsystem}/apticron_${::lsbdistcodename}.erb"
  }

  if $apticron_email == '' {
    $apticron_email = 'root'
  }

  if $apticron_diff_only == '' {
    $apticron_diff_only = '1'
  }

  if $apticron_listchanges_profile == '' {
    $apticron_listchanges_profile = 'apticron'
  }

  if $apticron_system == '' {
    $apticron_system = false
  }

  if $apticron_ipaddressnum == '' {
    $apticron_ipaddressnum = false
  }

  if $apticron_ipaddresses == '' {
    $apticron_ipaddresses = false
  }

  if $apticron_notifyholds == '' {
    $apticron_notifyholds = '0'
  }

  if $apticron_notifynew == '' {
    $apticron_notifynew = '0'
  }

  if $apticron_customsubject == '' {
    $apticron_customsubject = ''
  }

  package { 'apticron': ensure => $apticron_ensure_version }

  file { '/etc/apticron/apticron.conf':
    content => template($apticron_config),
    mode    => '0644', owner => root, group => root,
    require => Package['apticron'];
  }
}
