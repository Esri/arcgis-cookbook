# arcgis-workflow-manager Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Workflow Manager machine roles.

## System Requirements

Consult the ArcGIS Workflow Manager Server 10.9.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter  
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7
  * CentOS Linux 8

Enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_Server_Windows_1091_180041.exe
* ArcGIS_Workflow_Manager_Server_1091_180100.exe

Linux

* ArcGIS_Server_Linux_1091_180182.tar.gz
* ArcGIS_Workflow_Manager_Server_1091_180228.tar.gz

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
chef-client -z -j workflow-manager-fileserver.json
```

### First ArcGIS Workflow Manager Server Machine

```shell
chef-client -z -j workflow-manager-server.json
```

To federate ArcGIS Workflow Manager Server with Portal for ArcGIS and enable Workflow manager server function.

```shell
chef-client -z -j workflow-manager-server-federation.json
```

### Additional ArcGIS Workflow Manager Server Machines

```shell
chef-client -z -j workflow-manager-server-node.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-workflow-manager deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### workflow-manager-fileserver

Configures file shares for ArcGIS Workflow Manager Server config store and server directories.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### workflow-manager-server-install

Installs ArcGIS Workflow Manager Server without configuring it.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### workflow-manager-server

Installs and configures ArcGIS Workflow Manager Server.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify primary site administrator account user name.
* arcgis.server.admin_password - Specify primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server software authorization file.
* arcgis.server.directories_root - Replace 'FILESERVER' by the file server machine hostname or static IP address.
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address.
* arcgis.workflow_manager_server.authorization_file - Specify path to the ArcGIS Workflow Manager Server role software authorization file.

### workflow-manager-server-node

Installs ArcGIS Workflow Manager Server on the machine, authorizes the software, and joins the machine to an existing ArcGIS Server site.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Server site to join.
* arcgis.workflow_manager_server.authorization_file - Specify path to the ArcGIS Workflow Manager Server role software authorization file.

### workflow-manager-server-federation

Federates ArcGIS Workflows Manager Server with Portal for ArcGIS and enables Workflow Manager server function.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation..
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### workflow-manager-s3files

The role downloads ArcGIS Workflow Manager Server and Web App setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
