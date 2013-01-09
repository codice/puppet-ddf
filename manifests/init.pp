class ddf($package = "ddf-standard",
	  $version = "2.1.0.ALPHA11"){

	case $operatingsystem {
		centos: {
			package{ "java": name => "java-1.6.0-openjdk", ensure => installed }
			$java_home = "/usr/lib/jvm/jre-1.6.0-openjdk.x86_64"
		}
		ubuntu: { 
			exec { "apt-get update": } ->
			package{ "java": name => "openjdk-6-jre-headless", ensure => installed }
			$java_home = "/usr/lib/jvm/java-6-openjdk-amd64"
		}
	}

	service { "ddf":
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		subscribe => File["/usr/local/${package}-${version}/etc/DDF-wrapper.conf"],
		require => [	File["/usr/local/${package}-${version}/bin/DDF-wrapper"],
				File["/usr/local/${package}-${version}/etc/DDF-wrapper.conf"]]
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
		command => "wget https://nexus.macefusion.com/nexus/content/repositories/releases/ddf/${package}/${version}/${package}-${version}.zip --no-check-certificate",
		creates => "/tmp/${package}-${version}.zip",
		timeout => 3600,
		require => File["set_wgetrc"]
	}

	exec { "rm /root/.wgetrc":
		require => Exec["get_ddf"]
	} 

	exec { "stop_ddf":
    		command => "/etc/init.d/ddf stop",
	    	onlyif => "grep -c ddf /etc/init.d/ddf",
		returns => [0,1]
	}
		
	if $package == 'ddf-enterprise' {
	# Unpack the DDF distribution
		exec { "unzip /tmp/${version}/${package}-${version}.zip":
			cwd => "/usr/local",
			creates => "/usr/local/${package}-${version}",
			require => [Package["unzip"], Exec["get_ddf"], User['ddf']],
		} ->
		exec { "chown":
			command => "chown -R ddf:ddf /usr/local/${package}-${version}",
			require => [Exec["unzip /tmp/ddf.zip"], User['ddf']],
		} 
	} else {
		exec { "unzip":
			command => "unzip /tmp/${package}-${version}.zip; mv ddf-${version} ${package}-${version}",
			cwd => "/usr/local",
			creates => "/usr/local/${package}-${version}",
			require => [Package["unzip"], Exec["get_ddf"],  User['ddf']],
		} ->
		exec { "chown":
			command => "chown -R ddf:ddf /usr/local/${package}-${version}",
			require => [Exec["unzip"], User['ddf']],
		} 
	}

	# Setup the system service
	file { "/etc/init.d/ddf":
		notify => Service["ddf"],
		content => template("ddf/ddf.erb"),
		require => [Exec["chown"],Exec["stop_ddf"],File["/usr/local/${package}-${version}/etc/startup.properties"]],
		mode => 755,
	}
	file { "/usr/local/${package}-${version}/lib/libwrapper.so":
		source => "puppet:///modules/ddf/libwrapper.so",
		require => Exec["chown"],
		mode => 644
	}
	file { "/usr/local/${package}-${version}/lib/karaf-wrapper.jar":
		source => "puppet:///modules/ddf/karaf-wrapper.jar",
		require => Exec["chown"],
		mode => 644
	}
	file { "/usr/local/${package}-${version}/lib/karaf-wrapper-main.jar":
		source => "puppet:///modules/ddf/karaf-wrapper-main.jar",
		require => Exec["chown"],
		mode => 644
	}

	# Setup the appropriate wrapper
	if $architecture == 'x86_64' {  
		file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
			source => "puppet:///modules/ddf/DDF-wrapper",
			require => Exec["chown"],
			mode => 755,
		} 
	} else {
		file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
			source => "puppet:///modules/ddf/DDF-wrapper-32",
			require => Exec["chown"],
			mode => 755,
		} 
	}
	file { "/usr/local/${package}-${version}/etc/DDF-wrapper.conf":
		mode => 644,
		content => template("ddf/DDF-wrapper.conf.erb"),
		require => [File["/etc/init.d/ddf"],Exec["chown"]]
	}
	file { "/usr/local/${package}-${version}/etc/startup.properties":
		mode => 644,
		source => "puppet:///modules/ddf/startup.properties",
		require => Exec["chown"]
	}

}

