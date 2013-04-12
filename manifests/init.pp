class ddf($package = "ddf-standard",
	  $version = "2.2.0-ALPHA3", $repo_user = $repo_user, $repo_pass = $repo_pass){

	service { "iptables": ensure => false, enable => false }

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
				File["/usr/local/${package}-${version}/etc/DDF-wrapper.conf"],
        File["/etc/init.d/ddf"]]
	}

	# Ensure system dependencies are installed
	package{ "unzip": ensure => installed }
	
	user { "ddf":
		ensure => 'present'
	}

	exec { "get_ddf":
		cwd => "/tmp",
		command => "wget --user=${repo_user} --password=${repo_pass} https://nexus.macefusion.com/nexus/content/groups/everything/ddf/distribution/${package}/${version}/${package}-${version}.zip --no-check-certificate",
		creates => "/tmp/${package}-${version}.zip",
		timeout => 3600,
  } 
		
	if $package == 'ddf-enterprise' {
	# Unpack the DDF distribution
		exec { "unzip_enterprise":
      command => "unzip /tmp/${version}/${package}-${version}.zip",
			cwd => "/usr/local",
			creates => "/usr/local/${package}-${version}",
			require => [Package["unzip"], Exec["get_ddf"], User['ddf']],
		} 
	} else {
		exec { "unzip":
			command => "unzip /tmp/${package}-${version}.zip; mv ddf-${version} ${package}-${version}",
			cwd => "/usr/local",
			creates => "/usr/local/${package}-${version}",
			require => [Package["unzip"], Exec["get_ddf"],  User['ddf']],
      notify => File["/usr/local/${package}-${version}"]
		}
  }
  
  file { "/usr/local/${package}-${version}":
    ensure => directory
  }
  
	# Setup the system service
	file { "/etc/init.d/ddf":
		notify => Service["ddf"],
		content => template("ddf/ddf.erb"),
		require => File["/usr/local/${package}-${version}/etc/startup.properties"],
		mode => 755,
	}
	file { "/usr/local/${package}-${version}/lib/libwrapper.so":
		source => "puppet:///modules/ddf/libwrapper.so",
		mode => 644,
    require => File["/usr/local/${package}-${version}"]
	}
	file { "/usr/local/${package}-${version}/lib/karaf-wrapper.jar":
		source => "puppet:///modules/ddf/karaf-wrapper.jar",
		mode => 644,
    require => File["/usr/local/${package}-${version}"]
	}
	file { "/usr/local/${package}-${version}/lib/karaf-wrapper-main.jar":
		source => "puppet:///modules/ddf/karaf-wrapper-main.jar",
		mode => 644,
    require => File["/usr/local/${package}-${version}"]
	}

	# Setup the appropriate wrapper
	if $architecture == 'x86_64' {  
		file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
			source => "puppet:///modules/ddf/DDF-wrapper",
			mode => 755,
      require => File["/usr/local/${package}-${version}"]
		} 
	} else {
		file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
			source => "puppet:///modules/ddf/DDF-wrapper-32",
			mode => 755,
      require => File["/usr/local/${package}-${version}"]
		} 
	}
	file { "/usr/local/${package}-${version}/etc/DDF-wrapper.conf":
		mode => 644,
		content => template("ddf/DDF-wrapper.conf.erb"),
		require => [File["/etc/init.d/ddf"],File["/usr/local/${package}-${version}"]]
	}
	file { "/usr/local/${package}-${version}/etc/startup.properties":
		mode => 644,
		source => "puppet:///modules/ddf/startup.properties",
    require => File["/usr/local/${package}-${version}"]
	}

}

