# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt {

  # See README
  $real_apt_clean = $apt_clean ? {
    '' => 'auto',
    default => $apt_clean,
  }

  $use_volatile = $apt_use_volatile ? {
    ''      => false,
    default => $apt_use_volatile,
  }

  $include_src = $apt_include_src ? {
    ''      => false,
    default => $apt_include_src,
  }

  $use_next_release = $apt_use_next_release ? {
    ''      => false,
    default => $apt_use_next_release,
  }

  $debian_url = $apt_debian_url ? {
    ''      => 'http://ftp.debian.org/debian/',
    default => "${apt_debian_url}",
  }
  $security_url = $apt_security_url ? {
    ''      => 'http://security.debian.org/',
    default => "${apt_security_url}",
  }
  $backports_url = $apt_backports_url ? {
    ''      => 'http://backports.debian.org/debian-backports/',
    default => "${apt_backports_url}",
  }
  $volatile_url = $apt_volatile_url ? {
    ''      => 'http://volatile.debian.org/debian-volatile/',
    default => "${apt_volatile_url}",
  }

  package { apt:
    ensure => installed,
    require => undef,
  }

  # init $release, $next_release, $codename, $next_codename
  case $lsbdistcodename {
    '': {
      include lsb
      $codename = $lsbdistcodename
      $release = $lsbdistrelease
    }
    default: {
      $codename = $lsbdistcodename
      $release = debian_release($codename)
    }
  }
  $next_codename = debian_nextcodename($codename)
  $next_release = debian_nextrelease($release)

  case $custom_sources_list {
    '': {
      include apt::default_sources_list
    }
    default: {
      config_file { "/etc/apt/sources.list":
        content => $custom_sources_list,
      }
    }
  }

  case $custom_preferences {
    '': {
      include apt::default_preferences
    }
    default: {
      config_file { "/etc/apt/preferences":
        content => $custom_preferences,
        alias => "apt_config",
        require => File["/etc/apt/sources.list"];
      }
    }
  }

  if $apt_unattended_upgrades {
    include apt::unattended_upgrades
  }

  include common::moduledir
  $apt_base_dir = "${common::moduledir::module_dir_path}/apt"
  modules_dir { apt: }
  # watch apt.conf.d
  file { "/etc/apt/apt.conf.d": ensure => directory, checksum => mtime; }

  exec {
    # "&& sleep 1" is workaround for older(?) clients
    'refresh_apt':
      command => '/usr/bin/apt-get update && sleep 1',
      refreshonly => true,
      subscribe => [ File["/etc/apt/sources.list", "/etc/apt/preferences", "/etc/apt/apt.conf.d"],
                     Config_file["apt_config"] ];
      'update_apt':
        command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
        require => [ File["/etc/apt/sources.list", "/etc/apt/preferences"], Config_file["apt_config"] ],
        loglevel => info,
        # Another Semaphor for all packages to reference
        alias => "apt_updated";
  }

  ## This package should really always be current
  package { "debian-archive-keyring": ensure => latest }
  # backports uses the normal archive key now
  package { "debian-backports-keyring": ensure => absent }
        
  case $custom_key_dir {
    '': {
      exec { "/bin/true # no_custom_keydir": }
    }
    default: {
      file { "${apt_base_dir}/keys.d":
        source => "$custom_key_dir",
        recurse => true,
        mode => 0755, owner => root, group => root,
      }
      exec { "find ${apt_base_dir}/keys.d -type f -exec apt-key add '{}' \\; && apt-get update":
        alias => "custom_keys",
        subscribe => File["${apt_base_dir}/keys.d"],
        refreshonly => true,
        before => Config_file["apt_config"];
      }
    }
  }

  # workaround for preseeded_package component
  file { "/var/cache": ensure => directory }
  file { "/var/cache/local": ensure => directory }
  file { "/var/cache/local/preseeding": ensure => directory }
}     
