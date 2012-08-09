# puppet-ddf

A Puppet module for deploying a DDF node.

---

**Currently only supports initial deployment, and no subsequent Feature
action.  It is possible to extend this module with the provisioning of
the various configuration files required by Karaf and DDF.**

Once deployed, access is available via SSH to port 8101 on the remote node.  User credentials are specified in the ${ddf_home}/etc/users.properties file.

In order to download the DDF package from MACE you must add a 'wgetrc' file to the files/ subdirectory in the module and include the following:

```
user=Your_MACE_username
password=Your_MACE_password
```

Without this file in place, the Puppet execution will fail.  Without the proper credentials the execution will continue but the download will fail, causing the dependent tasks to fail.

The 'wgetrc' file will get deploy to /root/.wgetrc during the deployment, then removed following completion.