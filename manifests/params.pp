class apt::params () {
  $codename = $::lsbdistcodename
  $use_volatile = false
  $include_src = false
  $use_next_release = false
  $debian_url = 'http://http.debian.net/debian/'
  $security_url = 'http://security.debian.org/'
  $backports_url = $::lsbdistcodename ? {
    'wheezy' => $debian_url,
    default  => 'http://backports.debian.org/debian-backports/',
  }
  $volatile_url = 'http://volatile.debian.org/debian-volatile/'
  $ubuntu_url = 'http://archive.ubuntu.com/ubuntu'
  $repos = 'auto'
  $custom_preferences = ''
  $disable_update = false
  $use_security = true
  $use_backports = true
  $custom_key_dir = false
}
