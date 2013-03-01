# puppet-ddf

A Puppet module for deploying a basic/raw DDF node.

---

**Currently only supports initial deployment, and no subsequent Feature
action.  It is possible to extend this module with the provisioning of
the various configuration files required by Karaf and DDF.**

Once deployed, DDF access is available via SSH to port 8101 on the remote node.  User credentials are specified in the remote ${ddf_home}/etc/users.properties file.

---

I happen to be using this with [Vagrant](http://vagrantup.com) to rapidly provision a basic Ubuntu server with a DDF environment.

My manifest is super simple:

```
group { "puppet":
  ensure => "present",
}

Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

class { "ddf": 
  repo_user => 'repo.user',
  repo_pass => 'repo.pass',
  version => "ddf-standard", 
  package => "2.1.0.20130129-1341"
}
```