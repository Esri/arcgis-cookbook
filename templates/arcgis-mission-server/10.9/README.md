# arcgis-mission-server Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Mission Server machine roles.

## System Requirements

Consult the ArcGIS Mission Server 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 15, or
* Cinc Client 15

### Recommended ArcGIS Chef Cookbooks versions

* 3.7.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7

Enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_Mission_Server_Windows_109_177824.exe
* ArcGIS_Web_Adaptor_for_Microsoft_IIS_109_177789.exe

Linux

* ArcGIS_Mission_Server_Linux_109_177909.tar.gz
* ArcGIS_Web_Adaptor_Java_Linux_109_177888.tar.gz
* apache-tomcat-8.5.63.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)
* openjdk-11_linux-x64_bin.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install the recommended version of [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator/superuser using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-mission cookbook README file.

### File Server Machine

```shell
chef-client -z -j mission-server-fileserver.json
```

### First ArcGIS Mission Server Machine

```shell
chef-client -z -j mission-server.json
```

### ArcGIS Mission Server Web Adaptor Machine

```shell
chef-client -z -j mission-server-webadaptor.json
```

### Additional ArcGIS Mission Server Machines

```shell
chef-client -z -j mission-server-node.json
```

After all the server machines are configured federate ArcGIS Mission Server with Portal for ArcGIS.

```
chef-client -z -j mission-server-federation.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

ArcGIS Mission Server upgrade is similar to the initial deployment workflow.

1. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) recommended for the new ArcGIS Mission Server version into the Chef workspace directory.
3. Update the required attributes within the template JSON files. Copy the attribute changes from the JSON files used for the initial deployments.  
4. Run Chef client on all the deployment machines except for the file server machine as administrator/superuser in the same order as the initial deployment.

## Machine Roles

* mission-server-fileserver - configures file shares for ArcGIS Mission Server config store and server directories
* mission-server-install - installs ArcGIS Mission Server without authorizing or configuring it
* mission-server - installs ArcGIS Mission Server, authorizes the software, and creates site
* mission-server-node - installs ArcGIS Mission Server, authorizes the software, and joins the machine to existing site
* mission-server-unregister-machine - unregisters server machine from the site
* mission-server-webadaptor - installs ArcGIS Web Adaptor and registers it with ArcGIS Mission Server
* mission-server-federation - federates ArcGIS Mission Server with Portal for ArcGIS
* mission-server-s3files - downloads ArcGIS Mission Server setups archives from S3 bucket

### mission-server-fileserver

Installs NFS and configures shares for ArcGIS Mission Server config store and server directories.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### mission-sever-install

Installs ArcGIS Mission Server without authorizing or configuring it.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### mission-server

Installs ArcGIS Mission Server, authorizes the software, and creates site.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.mission_server.admin_username - Specify primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify primary site administrator account password.
* arcgis.mission_server.authorization_file - Specify path to the ArcGIS Mission Server role software authorization file.
* arcgis.mission_server.directories_root - Replace 'FILESERVER' by the file server machine hostname or static IP address.
* arcgis.mission_server.config_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### mission-server-node

Installs ArcGIS Mission Server, authorizes the software, and joins the machine to existing site.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.mission_server.admin_username - Specify primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify primary site administrator account password.
* arcgis.mission_server.authorization_file - Specify path to the ArcGIS Mission Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Mission Server site to join.

### mission-server-unregister-machine

* Unregisters the machine form ArcGIS Mission Server site.

### mission-server-webadaptor

Installs and configures Microsoft IIS web server on windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Mission Server.

Required attributes changes:

* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in IIS web server.
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file.
* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.mission_server.admin_username - Specify ArcGIS Mission Server primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify ArcGIS Mission Server primary site administrator account password.
* arcgis.mission_server.url - Specify ArcGIS Mission Server URL.
* arcgis.mission_server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - (Linux only) Specify password of the SSL certificate file.

### mission-server-federation

* Federates ArcGIS Mission Server with Portal for ArcGIS and enables MissionServer role.

Required attributes changes:

* arcgis.mission_server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.mission_server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.mission_server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.mission_server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation..
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### mission-server-s3files

The role downloads ArcGIS Mission Server setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
