# puppet-ddf

A Puppet module for deploying a DDF node.

---

**Currently only supports initial deployment, and no subsequent Feature
action.  It is possible to extend this module with the provisioning of
the various configuration files required by Karaf and DDF.**

Once deployed, access is available via SSH to port 8101 on the remote node.  User credentials are specified in the ${ddf_home}/etc/users.properties file.

In order for Puppet client to download the DDF package from MACE you must add a 'wgetrc' file to the files/ subdirectory in the module and include the following:

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