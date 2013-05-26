define apt::apt_conf(
  $ensure = 'present',
  $source = '',
  $content = undef
)
{
  if $ensure == 'present' {
    if $source == '' and $content == undef {
      fail("One of \$source or \$content must be specified for apt_conf ${name}")
    }

    if $source != '' and $content != undef {
      fail("Only one of \$source or \$content must specified for apt_conf ${name}")
    }
  }

  file { "/etc/apt/apt.conf.d/${name}":
    ensure => $ensure,
    owner  => root,
    group  => 0,
    mode   => '0644',
    notify => Exec["refresh_apt_${name}"],
  }

  if $source {
    File["/etc/apt/apt.conf.d/${name}"] {
      source => $source,
    }
  }
  else {
    File["/etc/apt/apt.conf.d/${name}"] {
      content => $content,
    }
  }

  exec {
    "refresh_apt_${name}":
      command     => '/usr/bin/apt-get update',
      refreshonly => true
  }
}
