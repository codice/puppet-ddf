# puppet-ddf

A Puppet module for deploying a basic/raw DDF node.

---

**Currently only supports initial deployment, and no subsequent Feature
action.  It is possible to extend this module with the provisioning of
the various configuration files required by Karaf and DDF.**

Once deployed, DDF access is available via SSH to port 8101 on the remote node.  User credentials are specified in the remote ${ddf_home}/etc/users.properties file.

---

I happen to be using this with [Vagrant](http://vagrantup.com) to rapidly provision a basic Ubuntu server with a DDF environment.

---

Requires Oracle Java: https://github.com/codice/ddf

I'm using this module to get 'er installed:

http://forge.puppetlabs.com/7terminals/java 

Make sure you download it as modules/java.

Just need to download from Oracle drop it in the modules/java/files subfolder of that java module and add to your site configuration.

My manifest is super simple:

```
group { "puppet":
  ensure => "present",
}

Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

java::setup {'jdk-7u25-linux-x64':
  source        => 'jdk-7u25-linux-x64.tar.gz',
  deploymentdir => '/usr/lib64/jvm/oracle-jdk7',
  user          => 'root',
  pathfile      => '/etc/profile.d/java.sh',
  cachedir      => "/tmp/java-setup-${name}"
} ->
class { "ddf": 
  package       => "ddf-standard", 
  version       => "2.2.0.RC1",
  java_home     => "/usr/lib64/jvm/oracle-jdk7",
  mvn_repos     => ["http://artifacts.codice.org/content/repositories/releases",
                "http://artifacts.codice.org/content/repositories/snapshots"],
  feature_repos => ["mvn:org.codice/opendx-features/1.0.1/xml/features"],
  features      => []
}

```
So, you can pass in extra Feature goodies, like a Maven repo, Feature repo and Features to start automatically.