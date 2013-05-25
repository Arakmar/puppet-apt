class apt::refresh_keys {

  include apt

  exec { "refresh_keys":
	  command => "apt-key adv --keyserver pool.sks-keyservers.net --refresh-keys"
  }
}
