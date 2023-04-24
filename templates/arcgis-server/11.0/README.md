---
layout: default
title: "arcgis-server template"
category: templates
item: arcgis-server
version: "11.0"
latest: true
---

# arcgis-server Deployment Template

Creates any of the following ArcGIS Server sites and federates them with an ArcGIS Enterprise deployment: GIS Server, ArcGIS GeoAnalytics Server, Raster Analytics Server, Image Server, and Knowledge Server.

## System Requirements

Consult the ArcGIS Server 11.0 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.0.0

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

* ArcGIS_Server_Windows_110_182874.exe

Linux

* ArcGIS_Server_Linux_110_182973.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for ArcGIS Server setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise cookbook README file.

### File Server Machine

```shell
chef-client -z -j arcgis-server-fileserver.json
```

### First ArcGIS Server Machine

```shell
chef-client -z -j arcgis-server.json
```

### Additional ArcGIS Server Machines

```shell
chef-client -z -j arcgis-server-node.json
```

### Additional GIS Server Federation Roles

If the ArcGIS Server site needs to be federated with an Enterprise portal:

* In GIS Server role

  ```shell
  chef-client -z -j gis-server-federation.json
  ```

* In ArcGIS GeoAnalytics Server role

  ```shell
  chef-client -z -j geoanalytics-federation.json
  ```

* In Raster Analytics Server role

  ```shell
  chef-client -z -j arcgis-server-raster-store.json
  chef-client -z -j rasteranalytics-federation.json
  ```

* In Image Server role

  ```shell
  chef-client -z -j arcgis-server-raster-store.json
  chef-client -z -j imagehosting-federation.json
  ```

* In Knowledge Server role

  ```shell
  chef-client -z -j knowledgeserver-federation.json
  ```

### ArcGIS Web Adaptor Machine

If ArcGIS Web Adaptor is required, use the arcgis-webadaptor deployment template to install and configure it.

## Install ArcGIS Server Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS Server, download ArcGIS Server patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j arcgis-server-patches.json
```

Check the list of patches specified by the arcgis.server.patches attribute in the arcgis-server-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j arcgis-server-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to upgrade an ArcGIS Server site using the deployment template if it was not initially deployed using an earlier version of the templates.

To upgrade an ArcGIS Server site deployed using the arcgis-server deployment template to the 11.0 version, you will need:

* ArcGIS Server 11.0 setup archive,
* ArcGIS Web Adaptor 11.0 setup archive, if Web Adaptors were installed in the initial deployment,
* ArcGIS Server 11.0 software authorization file,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading an ArcGIS Server deployment may take several hours. During that time, the deployment will be unavailable to the users.

Before starting the upgrade process, it's highly recommended to back up the ArcGIS Server site configuration. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading ArcGIS Server.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.0 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of the arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attributes values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new ArcGIS Server version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS software, upgrade the configuration management subsystem components:

1. Back up the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.9 or 10.9.1

Upgrading ArcGIS Server deployments from 10.9 or 10.9.1 to 11.0 requires upgrading all ArcGIS Server machines. The file server machine does not require any changes.

> Note that in 11.0, ArcGIS Web Adaptor is installed using the new arcgis-webadaptor deployment template.

1. Unregister ArcGIS Server Web Adaptors.

   Copy attributes from the original `arcgis-server-webadaptor.json` JSON file created from the 10.9 or 10.9.1 arcgis-server template to the `arcgis-server-webadaptor-unregister.json` file of the 11.0 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-server-webadaptor.json <arcgis-webadaptor 11.0 template>/arcgis-server-webadaptor-unregister.json
   ```

   Verify attributes are correct in `arcgis-server-webadaptor-unregister.json`

   On the first ArcGIS Server machine, run the following command:
  
   ```shell
   chef-client -z -j <arcgis-webadaptor 11.0 template>/arcgis-server-webadaptor-unregister.json
   ```

2. Upgrade the first ArcGIS Server machine.
  
   Copy attributes from the original `arcgis-server.json` JSON file created from the 10.9 or 10.9.1 arcgis-server template to the `arcgis-server.json` file of the 11.0 arcgis-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-server.json <arcgis-server 11.0 template>/arcgis-server.json
   ```

   Verify attributes are correct in `arcgis-server.json`

   On the first ArcGIS Server machine, run the following command:

   ```shell
   chef-client -z -j <arcgis-server 11.0 template>/arcgis-server.json
   ```

3. Upgrade the additional ArcGIS Server machines.

   Copy attributes from the original `arcgis-server-node.json` JSON file created from the 10.9 or 10.9.1 arcgis-server template to the `arcgis-server-node.json` fiile of the 11.0 arcgis-server template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-server-node.json <arcgis-server 11.0 template>/arcgis-server-node.json
   ```

   Verify that attributes are correct in `arcgis-server-node.json`.

   Run the following command to upgrade the ArcGIS Server node:

   ```shell
   chef-client -z -j <arcgis-server 11.0 template>/arcgis-server-node.json
   ```

   Repeat step 3 for each additional ArcGIS Server machine in the site.

4. Upgrade ArcGIS Web Adaptors used with the ArcGIS Server site.

   Copy attributes from the original `arcgis-server-webadaptor.json` JSON file created from the 10.9 or 10.9.1 arcgis-server template to the `arcgis-server-webadaptor.json` file of the 11.0 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-server-webadaptor.json <arcgis-webadaptor 11.0 template>/arcgis-server-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-server-webadaptor.json`.

   Run the following command to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 11.0 template>/arcgis-server-webadaptor.json
   ```

   Repeat step 4 for each ArcGIS Web Adaptor machine.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-server-files

The role downloads ArcGIS Server setup archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### arcgis-server-s3files

The role downloads ArcGIS Server setup archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-server-fileserver

Configures file shares for the ArcGIS Server configuration store and server directories.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-server-install

Installs ArcGIS Server on the machine without authorizing or configuring it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-server

Installs ArcGIS Server on the machine, authorizes the software, and creates an ArcGIS Server site.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify primary site administrator account user name.
* arcgis.server.admin_password - Specify primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file.
* arcgis.server.directories_root - Replace 'FILESERVER' with the file server machine hostname or static IP address.
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### arcgis-server-node

Installs ArcGIS Server on the machine, authorizes the software, and joins the machine to an existing ArcGIS Server site.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Server site to join.

### arcgis-server-patches

Downloads ArcGIS Server patches from the global ArcGIS software repository into a local patch folder.

### arcgis-server-patches-apply

Applies ArcGIS Server patches.

### arcgis-sever-raster-store

Registers a raster store with ArcGIS Server.

* arcgis.server.url - Specify ArcGIS Server URL.
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.

### gis-server-federation

Federates an ArcGIS GIS Server with Portal for ArcGIS.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### imagehosting-federation

Federates an ArcGIS Image Server with Portal for ArcGIS in the ImageHosting server role.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### knowledgeserver-federation

Federates an ArcGIS Knowledge Server with Portal for ArcGIS in the Knowledge Server role.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### geoanalytics-federation

Federates an ArcGIS GeoAnalytics Server with Portal for ArcGIS in the GeoAnalytics server role.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### rasteranalytics-federation

Federates an ArcGIS Image Server with Portal for ArcGIS in the RasterAnalytics server role.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### unfederate-server

Unfederates an ArcGIS Server site from Portal for ArcGIS.

Required attribute changes:

* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during unfederation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### unregister-machine

Unregisters a server machine from the ArcGIS Server site.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.url - Specify ArcGIS Server URL.
