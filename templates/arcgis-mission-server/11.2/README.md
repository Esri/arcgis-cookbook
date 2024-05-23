---
layout: default
title: "arcgis-mission-server template"
category: templates
item: arcgis-mission-server
version: "11.2"
latest: false
---

# arcgis-mission-server Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Mission Server machine roles.

## System Requirements

Consult the ArcGIS Mission Server 11.2 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.2.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 8

On Linux, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* ArcGIS_Mission_Server_Windows_112_188286.exe

Linux

* ArcGIS_Mission_Server_Linux_112_188361.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install the recommended version of [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-mission cookbook README file.

### File Server Machine

```shell
chef-client -z -j mission-server-fileserver.json
```

### First ArcGIS Mission Server Machine

```shell
chef-client -z -j mission-server.json
```

### Additional ArcGIS Mission Server Machines

```shell
chef-client -z -j mission-server-node.json
```

After all the Mission Server machines are configured, federate ArcGIS Mission Server with Portal for ArcGIS.

```
chef-client -z -j mission-server-federation.json
```

### ArcGIS Web Adaptor Machine

If ArcGIS Web Adaptor is required, use the arcgis-webadaptor deployment template to install and configure it.

## Install ArcGIS Mission Server Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS Mission Server, download ArcGIS Mission Server patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j mission-server-patches.json
```

Check the list of patches specified by the arcgis.mission_server.patches attribute in the mission-server-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j mission-server-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to use the templates to upgrade if the sites were not initially deployed using the templates.

To upgrade an ArcGIS Mission Server site deployed using the arcgis-mission-server deployment template to the 11.2 version, you will need:

* ArcGIS Mission Server 11.2 setup archive,
* ArcGIS Web Adaptor 11.2 setup archive, if Web Adaptors were installed in the initial deployment,
* ArcGIS Mission Server 11.2 software authorization file,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading an ArcGIS Mission Server deployment may take several hours. During that time, the deployment will be unavailable to the users.

Before you upgrade, it's recommended that you make backups of your deployment. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading ArcGIS Mission Server.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.2 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of the arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attribute values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new ArcGIS Mission Server version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS software, upgrade the configuration management subsystem components:

1. Back up the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.8 or 10.8.1

Upgrading ArcGIS Mission Server deployments to 11.2 requires upgrading all ArcGIS Mission Server machines.

> Note that in 11.2, ArcGIS Web Adaptor is installed using the new arcgis-webadaptor deployment template.

1. Upgrade the first ArcGIS Mission Server machine.
  
   Copy attributes from the original `mission-server-primary.json` JSON file created from the 10.8/10.8.1 arcgis-mission-server template to the `mission-server.json` file of the 11.2 arcgis-mission-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/mission-server-primary.json <arcgis-mission-server 11.2 template>/mission-server.json
   ```

   Verify that attributes are correct in `mission-server.json`.

   On the ArcGIS Mission Server machine, run the following command:

   ```shell
   chef-client -z -j <arcgis-mission-server 11.2 template>/mission-server.json
   ```

2. Upgrade the ArcGIS Web Adaptor for the ArcGIS Mission Server site.

   Copy attributes from the original `mission-server-primary.json` JSON file created from the 10.8/10.8.1 arcgis-mission-server template to the `arcgis-mission-server-webadaptor.json` file of the 11.2 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/mission-server-primary.json <arcgis-webadaptor 11.2 template>/arcgis-mission-server-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-mission-server-webadaptor.json`.

   Run the following command on the ArcGIS Mission Server machine to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 11.2 template>/arcgis-mission-server-webadaptor.json
   ```

### Upgrade from 10.9, 10.9.1, 11.0, or 11.1

Upgrading ArcGIS Mission Server deployments from 10.9, 10.9.1, 11.0, or 11.1 to 11.2 requires upgrading all ArcGIS Mission Server machines. The file server machine does not require any changes.

1. Upgrade the first ArcGIS Mission Server machine.
  
   Copy attributes from the original `mission-server.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-mission-server template to the `mission-server.json` file of the 11.2 arcgis-mission-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/mission-server.json <arcgis-mission-server 11.2 template>/mission-server.json
   ```

   Verify that attributes are correct in `mission-server.json`.

   On the first ArcGIS Mission Server machine, run the following command:

   ```shell
   chef-client -z -j <arcgis-mission-server 11.2 template>/mission-server.json
   ```

2. Upgrade additional ArcGIS Mission Server machines.

   Copy attributes from the original `mission-server-node.json` JSON file created from the 10.9, 10.9.1, 11.0, or 11.1 arcgis-mission-server template to the `mission-server-node.json` file of the 11.2 arcgis-mission-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/mission-server-node.json <arcgis-server 11.2 template>/mission-server-node.json
   ```

   Verify that attributes are correct in `mission-server-node.json`.

   On each additional ArcGIS Mission Server machine, run the following command to upgrade ArcGIS Mission Server:

   ```shell
   chef-client -z -j <arcgis-server 11.2 template>/mission-server-node.json
   ```

3. Upgrade ArcGIS Web Adaptor for the ArcGIS Mission Server site.

   Copy attributes from the original `mission-server-webadaptor.json` JSON file created from the 10.9, 10.9.1, 11.0, or 11.1 arcgis-mission-server template to the `arcgis-mission-server-webadaptor.json` file of the 11.2 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/mission-server-webadaptor.json <arcgis-webadaptor 11.2 template>/arcgis-mission-server-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-mission-server-webadaptor.json`.

   On each ArcGIS Mission Server Web Adaptor machine, run the following command to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 11.2 template>/arcgis-mission-server-webadaptor.json
   ```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### mission-server-fileserver

Installs NFS and configures shares for the ArcGIS Mission Server configuraton store and server directories.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### mission-sever-install

Installs ArcGIS Mission Server without authorizing or configuring it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### mission-server-patches

Downloads ArcGIS Mission Server patches from the global ArcGIS software repository into a local patch folder.

### mission-server-patches-apply

Applies ArcGIS Mission Server patches.

### mission-server

Installs ArcGIS Mission Server, authorizes the software, and creates a site.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account.
* arcgis.mission_server.admin_username - Specify primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify primary site administrator account password.
* arcgis.mission_server.authorization_file - Specify path to the ArcGIS Mission Server role software authorization file.
* arcgis.mission_server.directories_root - Replace 'FILESERVER' with the file server machine hostname or static IP address.
* arcgis.mission_server.config_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### mission-server-node

Installs ArcGIS Mission Server, authorizes the software, and joins the machine to the existing site.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account.
* arcgis.mission_server.admin_username - Specify primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify primary site administrator account password.
* arcgis.mission_server.authorization_file - Specify path to the ArcGIS Mission Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Mission Server site to join.

### mission-server-unregister-machine

* Unregisters the machine from the ArcGIS Mission Server site.

### mission-server-federation

* Federates ArcGIS Mission Server with Portal for ArcGIS and enables the MissionServer role.

Required attribute changes:

* arcgis.mission_server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.mission_server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.mission_server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.mission_server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### mission-server-files

The role downloads ArcGIS Mission Server setup archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### mission-server-s3files

The role downloads ArcGIS Mission Server setups archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
