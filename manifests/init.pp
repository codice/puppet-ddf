# Puppet module for deploying a basic DDF node (http://codice.github.com/ddf)
class ddf($package = "ddf-standard",
  $version = "2.2.0.RC1",
  $java_home = "/usr/local/java",
  $mvn_repos = [],
  $feature_repos = [],
  $features = [],
  $ddf_user = "ddf"  
){

  if !defined(Service["iptables"]) {
    service { "iptables": ensure => false, enable => false }
  }

  service { "ddf":
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    start       => "/etc/init.d/ddf start",
    stop        => "/etc/init.d/ddf stop",
    restart     => "/etc/init.d/ddf restart",
    subscribe   => [File["/usr/local/${package}-${version}/etc/DDF-wrapper.conf"],
      File["/etc/init.d/ddf"],
      File["/usr/local/${package}-${version}"],
      File["/usr/local/${package}-${version}/etc/org.ops4j.pax.url.mvn.cfg"],
      File["/usr/local/${package}-${version}/lib/karaf-wrapper.jar"],
      File["/usr/local/${package}-${version}/lib/karaf-wrapper-main.jar"],
      File["/usr/local/${package}-${version}/etc/org.apache.karaf.features.cfg"]],
    require     => [ File["/usr/local/${package}-${version}"],
        File["/usr/local/${package}-${version}/bin/DDF-wrapper"],
        File["/usr/local/${package}-${version}/etc/DDF-wrapper.conf"],
        File["/etc/init.d/ddf"],
        File["/usr/local/${package}-${version}/lib/libwrapper.so"],
        File["/usr/local/${package}-${version}/lib/karaf-wrapper.jar"],
        File["/usr/local/${package}-${version}/lib/karaf-wrapper-main.jar"],
        File["/usr/local/${package}-${version}/etc/org.ops4j.pax.url.mvn.cfg"],
        File["/usr/local/${package}-${version}/etc/org.apache.karaf.features.cfg"],
        User[$ddf_user]]
  }

  # Ensure system dependencies are installed
  user { $ddf_user:
    ensure      => 'present',
    managehome  => true
  }
  package{ "unzip": 
    ensure => 'installed' 
  } ->
  exec { "get_ddf":
    cwd     => "/tmp",
    command => "/usr/bin/wget http://artifacts.codice.org/content/repositories/releases/ddf/distribution/${package}/${version}/${package}-${version}.zip --no-check-certificate",
    creates => "/tmp/${package}-${version}.zip",
    timeout => 3600,
  }  
    
  if $package == 'ddf-enterprise' {
  # Unpack the DDF distribution
    exec { "unzip_enterprise":
      command => "/usr/bin/unzip /tmp/${version}/${package}-${version}.zip",
      cwd     => "/usr/local",
      creates => "/usr/local/${package}-${version}",
      require => [Package["unzip"], Exec["get_ddf"], User['ddf']],
    } 
  } else {
    exec { "unzip":
      command => "/usr/bin/unzip /tmp/${package}-${version}.zip; mv ddf-${version} ${package}-${version}",
      cwd     => "/usr/local",
      creates => "/usr/local/${package}-${version}",
      require => [Package["unzip"], Exec["get_ddf"],  User['ddf']],
      notify  => File["/usr/local/${package}-${version}"]
    }
  }
      
  # Setup the system service
  file { "/etc/init.d/ddf":
    notify  => Service["ddf"],
    content => template("ddf/ddf.erb"),
    require => File["/usr/local/${package}-${version}/etc/startup.properties"],
    mode    => "0755"
  }
  file { "/usr/local/${package}-${version}/lib/libwrapper.so":
    source  => "puppet:///modules/ddf/libwrapper.so",
    mode    => "0644",
    group   => $ddf_user,
    require => File["/usr/local/${package}-${version}"]
  }
  file { "/usr/local/${package}-${version}/lib/karaf-wrapper.jar":
    source  => "puppet:///modules/ddf/karaf-wrapper.jar",
    mode    => "0644",
    group   => $ddf_user,
    require => File["/usr/local/${package}-${version}"]
  }
  file { "/usr/local/${package}-${version}/lib/karaf-wrapper-main.jar":
    source  => "puppet:///modules/ddf/karaf-wrapper-main.jar",
    mode    => "0644",
    group   => $ddf_user,
    require => File["/usr/local/${package}-${version}"]
  }
  file { "/usr/local/${package}-${version}/etc/org.ops4j.pax.url.mvn.cfg":
    content => template("ddf/org.ops4j.pax.url.mvn.cfg.erb"),
    mode    => "0644",
    group   => $ddf_user                              
  }
  file { "/usr/local/${package}-${version}/etc/org.apache.karaf.features.cfg":
    content => template("ddf/org.apache.karaf.features.cfg.erb"),
    mode    => "0644",
    group   => $ddf_user                              
  }
  # Setup the appropriate wrapper
  if $::architecture == 'x86_64' {  
    file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
      source  => "puppet:///modules/ddf/DDF-wrapper",
      mode    => "0755",
      group   => $ddf_user,
      require => File["/usr/local/${package}-${version}"]
    } 
  } else {
    file { "/usr/local/${package}-${version}/bin/DDF-wrapper":
      source  => "puppet:///modules/ddf/DDF-wrapper-32",
      mode    => "0755",
      group   => $ddf_user,
      require => File["/usr/local/${package}-${version}"]
    } 
  }
  file { "/usr/local/${package}-${version}/etc/DDF-wrapper.conf":
    mode    => "0644",
    group   => $ddf_user,
    content => template("ddf/DDF-wrapper.conf.erb"),
    require => [File["/etc/init.d/ddf"],File["/usr/local/${package}-${version}"]]
  }
  file { "/usr/local/${package}-${version}/etc/startup.properties":
    mode    => "0644",
    group   => $ddf_user,
    source  => "puppet:///modules/ddf/startup.properties",
    require => File["/usr/local/${package}-${version}"]
  }
  file { "/usr/local/${package}-${version}":
    ensure  => "directory",
    group   => $ddf_user,
    owner   => $ddf_user,
    recurse => true,
                                
  }

}

