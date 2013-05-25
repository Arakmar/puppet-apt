# source.pp
# add an apt source

define apt::custom_repo(
	$location = '',
	$release = '',
	$repos = '',
	$filename = "${name}.list",
	$include_src = false,
	$required_packages = false,
	$key_fingerprint = false,
	$key_server = 'keyserver.ubuntu.com',
	$full_public_key = false,
	$pin = false
) {

	
	apt::sources_list { "${filename}":
		content => template("apt/custom_repo.erb")
	}

	if $pin != false {
		apt::pin { "${release}": priority => "${pin}" }
	}


	if $required_packages != false {
		exec { "${apt::provider} -y install ${required_packages}":
			subscribe => File["${name}.list"],
			refreshonly => true,
		}
	}

	if $full_public_key != false {
		exec { "apt_custom_repo_import_key_${name}" :
			command => "echo \"${full_public_key}\" | /usr/bin/apt-key add -",
			unless => "apt-key list | grep \"^pub.*`echo ${key_fingerprint} | sed 's/.*\(.\{8\}\)$/\1/'`\"",
			before => Apt::Sources_list["${filename}"],
		}
	}

	elsif $key_fingerprint != false {
		exec { "apt_custom_repo_import_key_${name}" :
			command => "/usr/bin/apt-key adv --keyserver ${key_server} --recv-keys ${key_fingerprint}",
			unless => "apt-key list | grep \"^pub.*`echo ${key_fingerprint} | sed 's/.*\(.\{8\}\)$/\1/'`\"",
			before => Apt::Sources_list["${filename}"]
		}
	}
}
