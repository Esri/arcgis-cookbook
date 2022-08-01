# arcgis-notebook-server Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Notebook Server machine roles.

## System Requirements

Consult the ArcGIS Notebook Server 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 15, or
* Cinc Client 15

### Recommended ArcGIS Chef Cookbooks versions

* 3.7.0

### Supported Platforms

* Ubuntu Server 18.04 LTS
* Ubuntu Server 20.04 LTS
* Red Hat Enterprise Linux Server 7 (Mirantis Container Runtime must be installed before running Chef)
* Red Hat Enterprise Linux Server 8 (Mirantis Container Runtime must be installed before running Chef)
* CentOS Linux 7

Enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

* ArcGIS_Notebook_Docker_Advanced_109_177823.tar.gz
* ArcGIS_Notebook_Docker_Standard_109_177822.tar.gz
* ArcGIS_Notebook_Server_Linux_109_177908.tar.gz
* ArcGIS_Notebook_Server_Samples_Data_Linux_109_177914.tar.gz
* ArcGIS_Server_Linux_109_177864.tar.gz
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

> For additional customization options see the list of supported attributes described in arcgis-notebooks cookbook README file.

### File Server Machine

```shell
chef-client -z -j notebook-server-fileserver.json
```

### First ArcGIS Notebook Server Machine

```shell
chef-client -z -j notebook-server.json
```

### ArcGIS Notebook Server Web Adaptor Machine

```shell
chef-client -z -j notebook-server-webadaptor.json
```

### Additional ArcGIS Notebook Server Machines

```shell
chef-client -z -j notebook-server-node.json
```

After all the server machines are configured federate ArcGIS Notebook Server with Portal for ArcGIS.

```
chef-client -z -j notebook-server-federation.json
```
## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

ArcGIS Notebook Server upgrade is similar to the initial deployment workflow.

1. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) recommended for the new ArcGIS Notebook Server version into the Chef workspace directory.
3. Update the required attributes within the template JSON files. Copy the attribute changes from the JSON files used for the initial deployments.  
4. Run Chef client on all the deployment machines except for the file server machine as administrator/superuser in the same order as the initial deployment.

## Machine Roles

* notebook-server-fileserver - configures file shares for ArcGIS Notebook Server config store and server directories
* notebook-server - installs Docker and ArcGIS Notebook Server, authorizes the software, and creates site
* notebook-server-node - installs Docker and ArcGIS Notebook Server, authorizes the software, and joins the machine to existing site
* notebook-server-unregister-node - unregisters server machine from the site
* notebook-server-webadaptor - installs ArcGIS Web Adaptor and registers it with ArcGIS Notebook Server
* notebook-server-federation - federates ArcGIS Notebook Server with Portal for ArcGIS
* notebook-server-s3files - downloads ArcGIS Notebook Server setups archives from S3 bucket

### notebook-server-fileserver

Installs NFS and configures shares for ArcGIS Notebook Server config store and server directories.

### notebook-server

Installs Docker and ArcGIS Notebook Server, authorizes the software, and creates site.

Required attributes changes:

* arcgis.notebook_server.admin_username - Specify primary site administrator account user name.
* arcgis.notebook_server.admin_password - Specify primary site administrator account password.
* arcgis.notebook_server.authorization_file - Specify path to the ArcGIS Notebook Server role software authorization file.
* arcgis.notebook_server.directories_root - Replace 'FILESERVER' by the file server machine hostname or static IP address.
* arcgis.notebook_server.config_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### notebook-server-node

Installs Docker and ArcGIS Notebook Server, authorizes the software, and joins the machine to existing site.

Required attributes changes:

* arcgis.notebook_server.admin_username - Specify primary site administrator account user name.
* arcgis.notebook_server.admin_password - Specify primary site administrator account password.
* arcgis.notebook_server.authorization_file - Specify path to the ArcGIS Notebook Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Notebook Server site to join.

### notebook-server-unregister-node

* Unregisters the machine form ArcGIS Notebook Server site.

### notebook-server-webadaptor

Installs and configures Microsoft IIS web server on windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Notebook Server.

Required attributes changes:

* arcgis.notebook_server.admin_username - Specify ArcGIS Notebook Server primary site administrator account user name.
* arcgis.notebook_server.admin_password - Specify ArcGIS Notebook Server primary site administrator account password.
* arcgis.notebook_server.url - Specify ArcGIS Notebook Server URL.
* arcgis.notebook_server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - Specify password of the SSL certificate file.

### notebook-server-federation

* Federates ArcGIS Notebook Server with Portal for ArcGIS and enables NotebookServer role.

Required attributes changes:

* arcgis.notebook_server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.notebook_server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.notebook_server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.notebook_server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation..
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### notebook-server-s3files

The role downloads ArcGIS Notebook Server setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
