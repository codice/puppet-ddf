class ddf($version = "enterprise-2.1.0.ALPHA3") {

	package{ "unzip": ensure => installed }
	package{ "openjdk-6-jre-headless": ensure => installed }
	package{ "postgresql-9.1-postgis": ensure => installed }

	service { "postgres": ensure => running }

	user { "ddf":
		ensure => 'present'
	}

	exec { "get_ddf":
		cwd => "/tmp",
		command => "wget https://dl.dropbox.com/u/1627760/package-${version}.zip -O ddf.zip",
		creates => "/tmp/ddf.zip",
		timeout => 600,
	}

	exec { "unzip /tmp/ddf.zip":
		cwd => "/usr/local",
		creates => "/usr/local/ddf-${version}",
		require => [Package["unzip"], Exec["get_ddf"], User['ddf']],
	}

	file { "/usr/local/ddf-${version}":
		owner => "ddf",
		group => "ddf",
		recurse => true,
		require => Exec["unzip /tmp/ddf.zip"],
	}

	file { "/etc/init.d/ddf":
		source => "puppet:///modules/ddf/ddf",
		require => File["/usr/local/ddf-${version}"],
		mode => 755
	}
	file { "/usr/local/ddf-${version}/lib/libwrapper.so":
		source => "puppet:///modules/ddf/libwrapper.so",
		require => File["/usr/local/ddf-${version}"],
		mode => 644
	}
	file { "/usr/local/ddf-${version}/lib/karaf-wrapper.jar":
		source => "puppet:///modules/ddf/karaf-wrapper.jar",
		require => File["/usr/local/ddf-${version}"],
		mode => 644
	}
	file { "/usr/local/ddf-${version}/lib/karaf-wrapper-main.jar":
		source => "puppet:///modules/ddf/karaf-wrapper-main.jar",
		require => File["/usr/local/ddf-${version}"],
		mode => 644
	}  
	file { "/usr/local/ddf-${version}/bin/DDF-wrapper":
		source => "puppet:///modules/ddf/DDF-wrapper",
		mode => 755,
	} 
	file { "/usr/local/ddf-${version}/etc/DDF-wrapper.conf":
		mode => 644,
		content => template("ddf/DDF-wrapper.conf.erb")
	}

	service { "ddf":
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require => [File["/etc/init.d/ddf"],
					File["/usr/local/ddf-${version}/bin/DDF-wrapper"],
					File["/usr/local/ddf-${version}/etc/DDF-wrapper.conf"],]
	}


}