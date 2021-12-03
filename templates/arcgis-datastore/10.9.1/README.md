# arcgis-datastore Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for ArcGIS Data Store machine roles.

## System Requirements

Consult the ArcGIS Data Store 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

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

For Linux deployments enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_DataStore_Windows_1091_180054.exe

Linux

* ArcGIS_DataStore_Linux_1091_180204.tar.gz

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

To upgrade base ArcGIS Data Store deployed using arcgis-datastore deployment template to 10.9.1 version you will need:

* ArcGIS Data Store 10.9.1 setup archive,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrade of ArcGIS Data Store deployment may take several hours, during that time the deployment will be unavailable.

Before starting the upgrade process, it's highly recommended to create a backup of your data store and store your backup files in a remote, secure location. To prevent operating system updates during the upgrade process it's recommended to install all the recommended/required OS updates before upgrading ArcGIS Data Store.

The attributes defined in the upgrade JSONs files must match the actual deployment configuration. To make upgrade JSON files, update the 10.9.1 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases the difference between the original and the new deployment template JSON files will be just in the value of arcgis.version attribute. In those cases the easiest way to make the upgrade JSON files is just to change arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version it's recommended to update the new deployment templates instead of the original JSON files.

Tool copy_attributes.rb can be used to copy attributes values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in templates/tools directory in the ArcGIS cookbooks archive. To execute copy_attributes.rb use chef-apply command that comes with Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After executing the tool, update the destination JSON file attributes specific to the new JSON file template and attributes specific to the new ArcGIS Data Store version.

> ArcGIS Server must be upgraded before upgrading ArcGIS Data Store.

### Upgrade from 10.9

Upgrading ArcGIS Data Store deployments from 10.9 to 10.9.1 requires upgrading all ArcGIS Data Store machines. The file server machine does not require any changes.

#### Upgrading Relational Data Store

1. Upgrade standby machine

   Copy attributes from the original `arcgis-datastore-relational-standby.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-install.json` and `arcgis-datastore-relational-standby.json` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-relational-standby.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-relational-standby.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-relational-standby.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-relational-standby.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 10.9.1 `arcgis-datastore-relational-standby.json` file for future upgrades from 10.9.1.

2. Upgrade primary machine

   Copy attributes from the original `arcgis-datastore-relational-primary.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-relational-primary` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-relational-primary.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-relational-primary.json
   ```

   Verify that attributes are correct in `arcgis-datastore-relational-primary.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-relational-primary.json
   ```

> Skip step 1 for single machine ArcGIS Data Store deployments.

#### Upgrade Tilecache Data Store in Primary/Standby Mode

1. Upgrade standby machine

   Copy attributes from the original `arcgis-datastore-tilecache-standby.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-standby.json` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-tilecache-standby.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-tilecache-standby.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-standby.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-standby.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 10.9.1 `arcgis-datastore-tilecache-standby.json` file for future upgrades from 10.9.1.

2. Upgrade primary machine

   Copy attributes from the original `arcgis-datastore-tilecache-primary.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-tilecache-primary` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-relational-primary.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-primary.json
   ```

   Verify that attributes are correct in `arcgis-datastore-tilecache-primary.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-primary.json
   ```

> Skip step 1 for single machine ArcGIS Data Store deployments.

#### Upgrade TileCache Data Store in Cluster Mode

1. Upgrade all machines in the cluster

   Copy attributes from the original `arcgis-datastore-tilecache-cluster-node.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-cluster-node.json` files of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-tilecache-cluster-node.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-tilecache-cluster-node.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-cluster-node.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-cluster-node.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 10.9.1 `arcgis-datastore-tilecache-cluster-node.json` file for future upgrades from 10.9.1.

2: Complete upgrade on any machine in the cluster

   Copy attributes from the original `arcgis-datastore-tilecache-cluster.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-tilecache-cluster` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-relational-cluster.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-cluster.json
   ```

   Verify that attributes are correct in `arcgis-datastore-tilecache-cluster.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-tilecache-cluster.json
   ```

> Skip step 1 for single machine ArcGIS Data Store deployments.

#### Upgrade Spatiotemporal Data Store

1. Upgrade all machines in the cluster

   Copy attributes from the original `arcgis-datastore-spatiotemporal-node.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-install.json` and `arcgis-datastore-spatiotemporal-node.json` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-spatiotemporal-node.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-spatiotemporal-node.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-spatiotemporal-node.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-spatiotemporal-node.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 10.9.1 `arcgis-datastore-spatiotemporal-node.json` file for future upgrades from 10.9.1.

2. Complete upgrade on any machine in the cluster

   Copy attributes from the original `arcgis-datastore-spatiotemporal.json` JSON file created from 10.9 arcgis-datastore template to `arcgis-datastore-spatiotemporal` of 10.9.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-datastore-spatiotemporal.json <arcgis-datastore 10.9.1 template>/arcgis-datastore-spatiotemporal.json
   ```

   Verify that attributes are correct in `arcgis-datastore-spatiotemporal.json`.

   Execute the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 10.9.1 template>/arcgis-datastore-spatiotemporal.json
   ```

> Skip step 1 for single machine ArcGIS Data Store deployments.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

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

### arcgis-datastore-install

Installs ArcGIS Data Store without configuring it.

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
