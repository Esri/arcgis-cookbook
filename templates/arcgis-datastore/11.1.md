---
layout: default
title: "arcgis-datastore template"
category: templates
item: arcgis-datastore
version: "11.1"
latest: true
---

# arcgis-datastore Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for ArcGIS Data Store machine roles.

## System Requirements

Consult the ArcGIS Data Store 11.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.1.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 8

For Linux deployments, enable running sudo without a password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_DataStore_Windows_111_185221.exe

Linux

* ArcGIS_DataStore_Linux_111_185305.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles, though this is not recommended especially for spatiotemporal big data stores or graph stores).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise cookbook README file.

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

### Graph Store

On the graph store machine:

```shell
chef-client -z -j arcgis-datastore-graph.json
```

## Install ArcGIS Data Store Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS Data Store, download ArcGIS Data Store patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j arcgis-datastore-patches.json
```

Check the list of patches specified by the arcgis.data_store.patches attribute in the arcgis-datastore-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j arcgis-datastore-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to use the templates to upgrade if the data stores were not initially deployed using the templates.

To upgrade an ArcGIS Data Store deployed using the arcgis-datastore deployment template to the 11.1 version, you will need:

* ArcGIS Data Store 11.1 setup archive,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading the ArcGIS Data Store deployment may take several hours. During that time, the deployment will be unavailable.

Before starting the upgrade process, it's highly recommended to create a backup of your data store and store your backup files in a remote, secure location. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading ArcGIS Data Store.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.1 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of the arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attribute values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new ArcGIS Data Store version.

> ArcGIS Server must be upgraded before upgrading ArcGIS Data Store.

### Upgrade from 10.9 or 10.9.1

Upgrading ArcGIS Data Store deployments from 10.9, 10.9.1, or 11.0 to 11.1 requires upgrading all ArcGIS Data Store machines. The file server machine does not require any changes.

#### Upgrading Relational Data Store

> Skip step 1 for single machine ArcGIS Data Store deployments.

1. Upgrade the standby machine.

   Copy attributes from the original `arcgis-datastore-relational-standby.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-install.json` and `arcgis-datastore-relational-standby.json` files of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-relational-standby.json <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-relational-standby.json <arcgis-datastore 11.1 template>/arcgis-datastore-relational-standby.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-relational-standby.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 11.1 `arcgis-datastore-relational-standby.json` file for future upgrades from 11.1.

2. Upgrade the primary machine.

   Copy attributes from the original `arcgis-datastore-relational-primary.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-relational-primary.json` file of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-relational-primary.json <arcgis-datastore 11.1 template>/arcgis-datastore-relational-primary.json
   ```

   Verify that attributes are correct in `arcgis-datastore-relational-primary.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-relational-primary.json
   ```

#### Upgrade Tile Cache Data Store in Primary-Standby Mode

> Skip step 1 for single machine ArcGIS Data Store deployments.

1. Upgrade the standby machine.

   Copy attributes from the original `arcgis-datastore-tilecache-standby.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-standby.json` files of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-tilecache-standby.json <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-tilecache-standby.json <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-standby.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-standby.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 11.1 `arcgis-datastore-tilecache-standby.json` file for future upgrades from 11.1.

2. Upgrade the primary machine.

   Copy attributes from the original `arcgis-datastore-tilecache-primary.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-tilecache-primary.json` file of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-relational-primary.json <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-primary.json
   ```

   Verify that attributes are correct in `arcgis-datastore-tilecache-primary.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-primary.json
   ```


#### Upgrade Tile Cache Data Store in Cluster Mode

> Skip step 1 for single machine ArcGIS Data Store deployments.

1. Upgrade all machines in the cluster.

   Copy attributes from the original `arcgis-datastore-tilecache-cluster-node.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-cluster-node.json` files of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-tilecache-cluster-node.json <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-tilecache-cluster-node.json <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-cluster-node.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-tilecache-cluster-node.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 11.1 `arcgis-datastore-tilecache-cluster-node.json` file for future upgrades from 11.1.

2: Complete the upgrade on any machine in the cluster.

   Copy attributes from the original `arcgis-datastore-tilecache-cluster.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-tilecache-cluster.json` file of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-relational-cluster.json <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-cluster.json
   ```

   Verify that attributes are correct in `arcgis-datastore-tilecache-cluster.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-tilecache-cluster.json
   ```

#### Upgrade Spatiotemporal Big Data Store

1. Upgrade all machines in the cluster

   Copy attributes from the original `arcgis-datastore-spatiotemporal-node.json` JSON file created from 10.9, 10.9.1, or 11.0 arcgis-datastore template to `arcgis-datastore-install.json` and `arcgis-datastore-spatiotemporal-node.json` of 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-spatiotemporal-node.json <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 or 10.9.1 JSON files>/arcgis-datastore-spatiotemporal-node.json <arcgis-datastore 11.1 template>/arcgis-datastore-spatiotemporal-node.json
   ```

   Verify that attributes are correct in `arcgis-datastore-install.json` and `arcgis-datastore-spatiotemporal-node.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-install.json
   ```

   Save the updated 11.1 `arcgis-datastore-spatiotemporal-node.json` file for future upgrades from 11.1.

2. Complete the upgrade on any machine in the cluster

   Copy attributes from the original `arcgis-datastore-spatiotemporal.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-datastore template to the `arcgis-datastore-spatiotemporal.json` file of the 11.1 arcgis-datastore template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9, 10.9.1, or 11.0 JSON files>/arcgis-datastore-spatiotemporal.json <arcgis-datastore 11.1 template>/arcgis-datastore-spatiotemporal.json
   ```

   Verify that attributes are correct in `arcgis-datastore-spatiotemporal.json`.

   Run the following command to upgrade ArcGIS Data Store:

   ```shell
   chef-client -z -j <arcgis-datastore 11.1 template>/arcgis-datastore-spatiotemporal.json
   ```

> Skip step 1 for single machine ArcGIS Data Store deployments.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-datastore-files

The role downloads ArcGIS Data Store setups archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by arcgis.repository.local_archives attribute.

If arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

The following attributes are required:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### arcgis-datastore-s3files

The role downloads ArcGIS Data Store setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-datastore-fileserver

Configures file shares for ArcGIS Data Store backup directories.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-datastore-install

Installs ArcGIS Data Store without configuring it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-datastore-patches

Downloads ArcGIS Data Store patches from the global ArcGIS software repository into a local patch folder.

### arcgis-datastore-patches-apply

Applies ArcGIS Data Store patches.

### arcgis-datastore-relational-primary

Installs relational ArcGIS Data Store, registers it with ArcGIS Server, and configures a backup location.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.relational.backup_location - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### arcgis-datastore-relational-standby

Installs relational ArcGIS Data Store and registers it with ArcGIS Server.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-spatiotemporal

Installs spatiotemporal big data store, registers it with ArcGIS Server, and configures a backup location.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.spatiotemporal.backup_location - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### arcgis-datastore-spatiotemporal-node

Installs spatiotemporal big data store and registers it with ArcGIS Server.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-tilecache-primary

Installs tile cache ArcGIS Data Store, registers it with ArcGIS Server, and configures backup locations.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.tilecache.backup_location - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### arcgis-datastore-tilecache-standby

Installs tile cache ArcGIS Data Store and registers it with ArcGIS Server.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.

### arcgis-datastore-graph

Installs graph store, registers it with ArcGIS Server, and configures backup location.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify private URL of ArcGIS Server site to register the data store.
* arcgis.data_store.graph.backup_location - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### arcgis-datastore-remove-machine

Removes the local machine from ArcGIS Data Store.
