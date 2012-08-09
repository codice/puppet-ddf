class ddf($package = "enterprise",
		  $version = "2.1.0.ALPHA3") {

	case $operatingsystem {
		centos: {
			package{ "postgresql-server": ensure => installed }
			package{ "java": name => "java-1.6.0-openjdk", ensure => installed}
			$java_home = "/usr/lib/jvm/jre-1.6.0-openjdk.x86_64"
		}
		ubuntu: {
			package{ "java": name => "openjdk-6-jre-headless", ensure => installed }

			# Unfortunately this only exists in Ubuntu
			package{ "postgresql-9.1-postgis": ensure => installed }

			$java_home = "/usr/lib/jvm/java-6-openjdk-amd64"
		}
	}


	# Ensure system dependencies are installed
	package{ "unzip": ensure => installed }
	
	user { "ddf":
		ensure => 'present'
	}

	# Get the DDF distribution
	file { "set_wgetrc":
		path => "/root/.wgetrc",
		source => "puppet:///modules/ddf/wgetrc",
		owner => "root",
		group => "root"
	}

	exec { "get_ddf":
		cwd => "/tmp",
		command => "wget https://visualsvn.macefusion.com/svn/DDF/file_releases/ddf/${version}/package-${package}-${version}.zip -O ddf.zip --no-check-certificate",
		creates => "/tmp/ddf.zip",
		timeout => 600,
		require => File["set_wgetrc"]
	}

	exec { "rm /root/.wgetrc":
		require => Exec["get_ddf"]
	}

	# Unpack the DDF distribution
	exec { "unzip /tmp/ddf.zip":
		cwd => "/usr/local",
		creates => "/usr/local/ddf-${package}-${version}",
		require => [Package["unzip"], Exec["get_ddf"], User['ddf']],
	}

	file { "/usr/local/ddf-${package}-${version}":
		owner => "ddf",
		group => "ddf",
		recurse => true,
		require => Exec["unzip /tmp/ddf.zip"],
	}

	# Setup the system service
	file { "/etc/init.d/ddf":
		content => template("ddf/ddf.erb"),
		require => File["/usr/local/ddf-${package}-${version}"],
		mode => 755
	}
	file { "/usr/local/ddf-${package}-${version}/lib/libwrapper.so":
		source => "puppet:///modules/ddf/libwrapper.so",
		require => File["/usr/local/ddf-${package}-${version}"],
		mode => 644
	}
	file { "/usr/local/ddf-${package}-${version}/lib/karaf-wrapper.jar":
		source => "puppet:///modules/ddf/karaf-wrapper.jar",
		require => File["/usr/local/ddf-${package}-${version}"],
		mode => 644
	}
	file { "/usr/local/ddf-${package}-${version}/lib/karaf-wrapper-main.jar":
		source => "puppet:///modules/ddf/karaf-wrapper-main.jar",
		require => File["/usr/local/ddf-${package}-${version}"],
		mode => 644
	}  
	file { "/usr/local/ddf-${package}-${version}/bin/DDF-wrapper":
		source => "puppet:///modules/ddf/DDF-wrapper",
		mode => 755,
	} 
	file { "/usr/local/ddf-${package}-${version}/etc/DDF-wrapper.conf":
		mode => 644,
		content => template("ddf/DDF-wrapper.conf.erb")
	}

	service { "ddf":
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require => [File["/etc/init.d/ddf"],
					File["/usr/local/ddf-${package}-${version}/bin/DDF-wrapper"],
					File["/usr/local/ddf-${package}-${version}/etc/DDF-wrapper.conf"],]
	}


}