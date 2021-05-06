# arcgis-datastore Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for ArcGIS Data Store machine roles.

## System Requirements

Consult the ArcGIS Data Store 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

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
  * CentOS Linux 8

For Linux deployments enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_DataStore_Windows_109_177788.exe

Linux

* ArcGIS_DataStore_Linux_109_177887.tar.gz

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator/superuser using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-enterprise cookbook README file.

### File Server Machine

```shell
chef-client -z -j arcgis-datastore-fileserver.json
```

### Relational Data Store

On the primary machine:

```shell
chef-client -z -j arcgis-datastore-relational-primary.json
```

On the standby machine:

```shell
chef-client -z -j arcgis-datastore-relational-standby.json
```

### Tile Cache Data Store in Cluster Mode

On the first machine:

```shell
chef-client -z -j arcgis-datastore-tilecache-cluster.json
```

On all additional machines:

```shell
chef-client -z -j arcgis-datastore-tilecache-cluster-node.json
```

### Tile Cache Data Store in Primary-standby Mode

On the primary machine:

```shell
chef-client -z -j arcgis-datastore-tilecache-primary.json
```

On the standby machine:

```shell
chef-client -z -j arcgis-datastore-tilecache-standby.json
```

### Spatiotemporal Big Data Store

On the first machine:

```shell
chef-client -z -j arcgis-datastore-spatiotemporal.json
```

On all additional machines:

```shell
chef-client -z -j arcgis-datastore-spatiotemporal-node.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-datastore deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## JSON Files Included in the Template

* arcgis-datastore-s3files - downloads ArcGIS Server setups archives from S3 bucket
* arcgis-datastore-fileserver - configures file shares for ArcGIS Data Store backup directories.
* arcgis-datastore-relational-primary - installs relational ArcGIS Data Store, registers it with ArcGIS Server, and configures backup location
* arcgis-datastore-relational-standby - installs relational ArcGIS Data Store and registers it with ArcGIS Server
* arcgis-datastore-spatiotemporal - installs Spatiotemporal Big Data Store, registers it with ArcGIS Server, and configures backup location
* arcgis-datastore-spatiotemporal-node - installs Spatiotemporal Big Data Store and registers it with ArcGIS Server
* arcgis-datastore-tilecache-cluster - installs tile cache ArcGIS Data Store, registers it in cluster mode with ArcGIS Server, and configures backup locations
* arcgis-datastore-tilecache-cluster-node - installs tile cache ArcGIS Data Store and registers it in cluster mode with ArcGIS Server
* arcgis-datastore-tilecache-primary - installs tile cache ArcGIS Data Store, registers it in primaryStandby mode with ArcGIS Server, and configures backup locations
* arcgis-datastore-tilecache-standby - installs tile cache ArcGIS Data Store and registers it in primaryStandby mode with ArcGIS Server
* arcgis-datastore-remove-machine - removes machine from ArcGIS Data Store

### arcgis-datastore-s3files

The role downloads ArcGIS Data Store setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-datastore-fileserver

Configures file shares for ArcGIS Data Store backup directories.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-datastore-relational-primary

Installs relational ArcGIS Data Store, registers it with ArcGIS Server, and configures backup location.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.relational.backup_location - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### arcgis-datastore-relational-standby

Installs relational ArcGIS Data Store and registers it with ArcGIS Server.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-spatiotemporal

Installs Spatiotemporal Big Data Store, registers it with ArcGIS Server, and configures backup location.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.spatiotemporal.backup_location - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### arcgis-datastore-spatiotemporal-node

Installs Spatiotemporal Big Data Store and registers it with ArcGIS Server.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-tilecache-primary

Installs tile cache ArcGIS Data Store, registers it with ArcGIS Server, and configures backup locations.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.tilecache.backup_location - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### arcgis-datastore-tilecache-standby

Installs tile cache ArcGIS Data Store and registers it with ArcGIS Server.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-remove-machine

Removes the local machine from ArcGIS Data Store.
