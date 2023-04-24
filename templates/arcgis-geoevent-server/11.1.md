---
layout: default
title: "arcgis-geoevent-server template"
category: templates
item: arcgis-geoevent-server
version: "11.1"
latest: true
---

# arcgis-geoevent-server Deployment Template

Creates an ArcGIS GeoEvent Server deployment.

## System Requirements

Consult the ArcGIS GeoEvent Server 11.1 system requirements documentation for the required/recommended hardware specification.

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

For Linux deployments, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* ArcGIS_GeoEvent_Server_111_185251.exe
* ArcGIS_Server_Windows_111_185208.exe

Linux

* ArcGIS_GeoEvent_Server_111_185315.tar.gz
* ArcGIS_Server_Linux_111_185292.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise and arcgis-geoevent cookbooks README files.

### File Server Machine

```shell
chef-client -z -j geoevent-server-fileserver.json
```

### ArcGIS GeoEvent Server Machine

```shell
chef-client -z -j geoevent-server.json
```

### ArcGIS Web Adaptor Machine

If ArcGIS Web Adaptor is required, use the arcgis-webadaptor deployment template to install and configure it.

## Install ArcGIS GeoEvent Server Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS GeoEvent Server, download ArcGIS GeoEvent Server patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j geoevent-server-patches.json
```

Check the list of patches specified by the arcgis.geoevent.patches attribute in the geoevent-server-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j geoevent-server-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

To upgrade an ArcGIS GeoEvent Server site deployed using the arcgis-geoevent-server deployment template to the 11.1 version, you will need:

* ArcGIS Server 11.1 setup archive,
* ArcGIS GeoEvent Server 11.1 setup archive,
* ArcGIS Web Adaptor 11.1 setup archive, if Web Adaptors were installed in the initial deployment,
* ArcGIS Server 11.1 and ArcGIS GeoEvent Server software authorization files,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading the ArcGIS GeoEvent Server deployment may take several hours. During that time, the deployment will be unavailable to the users.

Before starting the upgrade process, it's highly recommended to export your GeoEvent Server configuration using ArcGIS GeoEvent Manager and back up any installed or added components. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading ArcGIS GeoEvent Server.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.1 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of the arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attribute values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new ArcGIS GeoEvent Server version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS GeoEvent software, upgrade the configuration management subsystem components:

1. Back up the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.9, 10.9.1, or 11.0

Upgrading ArcGIS Server deployments from 10.9, 10.9.1, or 11.0 to 11.1 requires upgrading all ArcGIS Server machines. The file server machine does not require any changes. Steps 1 and 3 are not required if the deployment does not use ArcGIS Web Adaptor.

> The GeoEvent Server configuration will not be automatically upgraded as a part of this installation and will need to be manually imported after successful completion of the installation.

> In 10.9.1 and 11.0, ArcGIS Web Adaptor is installed using the `arcgis-server-webadaptor.json` JSON file from the new arcgis-webadaptor deployment template.

> The 10.9 arcgis-geoevent-server deployment template did not support ArcGIS GeoEvent Server deployments with multiple server machines. However, it provided ability to configure ArcGIS Server config store and server directories using network shares, so new server machines could be added after upgrading to ArcGIS GeoEvent Server 11.1.

1. Unregister ArcGIS Web Adaptor.

   Copy attributes from the original `geoevent-server-webadaptor.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-geoevent-server template to the `arcgis-server-webadaptor-unregister.json` file of the 11.1 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/geoevent-server-webadaptor.json <arcgis-webadaptor 11.1 template>/arcgis-server-webadaptor-unregister.json
   ```

   Verify attributes are correct in `arcgis-server-webadaptor-unregister.json`

   On either an ArcGIS Server or an ArcGIS Web Adaptor machine, run the following command:
  
   ```shell
   chef-client -z -j <arcgis-webadaptor 11.1 template>/arcgis-server-webadaptor-unregister.json
   ```

2. Upgrade the ArcGIS GeoEvent Server machine.
  
   Copy attributes from the original `geoevent-server.json` JSON file created from the 10.9, 10.9.1, or 11.0 arcgis-geoevent-server template to the `geoevent-server.json` file of the 11.1 arcgis-geoevent-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/geoevent-server.json <arcgis-geoevent-server 11.1 template>/geoevent-server.json
   ```

   Verify attributes are correct in `geoevent-server.json`

   On the ArcGIS GeoEvent Server machine, run the following command:

   ```shell
   chef-client -z -j <arcgis-geoevent-server 11.1 template>/geoevent-server.json
   ```

3. Upgrade ArcGIS Web Adaptor.

   Copy attributes from the original `geoevent-server-webadaptor.json` JSON file created from the 10.9 or 10.9.1 arcgis-geoevent-server template to the `arcgis-server-webadaptor.json` file of the 11.1 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-server-webadaptor.json <arcgis-webadaptor 11.1 template>/arcgis-server-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-server-webadaptor.json`.

   Run the following command to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 11.1 template>/arcgis-server-webadaptor.json
   ```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### geoevent-server-files

The role downloads ArcGIS GeoEvent Server setups archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### geoevent-server-s3files

The role downloads ArcGIS GeoEvent Server setups archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### geoevent-server-fileserver

Configures file shares for the ArcGIS GeoEvent Server configuration store and server directories.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### geoevent-server-install

Installs ArcGIS Server and ArcGIS GeoEvent Server without authorizing or configuring them.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### geoevent-server-patches

Downloads ArcGIS GeoEvent Server patches from the global ArcGIS software repository into a local patch folder.

### geoevent-server-patches-apply

Applies ArcGIS GeoEvent Server patches.

### geoevent-server

Installs ArcGIS Server and ArcGIS GeoEvent Server, authorizes the software, and creates ArcGIS Server site.

Required attribute changes:

* arcgis.geoevent.authorization_file - Specify path to the ArcGIS GeoEvent Server role software authorization file.
* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify primary site administrator account user name.
* arcgis.server.admin_password - Specify primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server software authorization file.
* arcgis.server.directories_root - Replace 'FILESERVER' with the file server machine hostname or static IP address.
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address.
* arcgis.server.keystore_file - Specify path to the SSL certificate file in PKCS12 format that will be installed with ArcGIS Server.
* arcgis.server.keystore_password - Specify password of the SSL certificate file.
* arcgis.server.system_properties.WebSocketContextURL - Specify web socket reverse proxy server URL.
* arcgis.server.system_properties.WebContextURL - Specify reverse proxy server URL.

### geoevent-server-reset (Windows only)

Administratively resets GeoEvent Server.

> Deletes the Apache ZooKeeper files (to administratively clear the GeoEvent Server configuration), the product’s runtime files (to force the system framework to be rebuilt), and removes previously received event messages (by deleting Kafka topic queues from disk). This is how system administrators reset a GeoEvent Server instance to look like the product has just been installed.

> If you have custom components in the C:\Program Files\ArcGIS\Server\GeoEvent\deploy folder, move these from the \deploy folder to a local temporary folder, while GeoEvent Server is running, to prevent the component from being restored (from the distributed configuration store) when GeoEvent Server is restarted. Also, make sure you have a copy of the most recent XML export of your GeoEvent Server configuration if you want to save the elements you have created.
