# puppet-ddf

A Puppet module for deploying a basic/raw DDF node.

---

**Currently only supports initial deployment, and no subsequent Feature
action.  It is possible to extend this module with the provisioning of
the various configuration files required by Karaf and DDF.**

Once deployed, DDF access is available via SSH to port 8101 on the remote node.  User credentials are specified in the remote ${ddf_home}/etc/users.properties file.

---

In order for Puppet client to download the DDF package from [MACE](http://www.macefusion.com/) you must add a 'wgetrc' file to the files/ subdirectory in the module and include the following:

```
user=Your_MACE_username
password=Your_MACE_password
```

Without this file in place, the Puppet execution will fail.  Without the proper credentials the execution will continue but the download will fail, causing the dependent tasks to fail.

The local ```./files/wgetrc``` file will get deployed to the target's ```/root/.wgetrc``` during the deployment, then removed following completion of configuration management activities (the end of the Puppet run).

The wgetrc file you create is in the .gitignore file so it won't accidentally get committed to the SCM repo.

```
Ensure the proper mode for the wgetrc file on the PuppetMaster side to prevent readability by
anyone other than the user running the PuppetMaster.  In local development environments 
(e.g. Vagrant) this is equally important.
```

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

class { "ddf": }
```

---

The DDF module is currently including the installation of PostgreSQL.  It isn't really required, and will likely be removed in the near future.