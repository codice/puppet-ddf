class ddf($version = "enterprise-2.1.0.ALPHA3") {

	package{ "unzip": ensure => installed }
	package{ "openjdk-6-jre-headless": ensure => installed}

	user { "ddf":
		ensure => 'present'
	}

	exec { "get_ddf":
		cwd => "/tmp",
		command => "wget https://dl.dropbox.com/u/1627760/package-${version}.zip -O ddf.zip",
		creates => "/tmp/ddf.zip"

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