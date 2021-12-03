# arcgis-pro Deployment Template

Installs ArcGIS Pro 2.8.

## System Requirements

Consult the ArcGIS Pro 2.8 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows 10 
  * Windows 10 Pro

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

* ArcGISPro_28_177688.exe

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-pro cookbook README file.

### Concurrent Use ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-concurrent-use.json
```

### Single Use ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-single-use.json
```

### Named User ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-named-user.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-pro deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-pro-s3files

Downloads ArcGIS Pro setups archive from S3 bucket.

The role requires AWS Tools for PowerShell to be installed on the machine.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-pro-install

Installs ArcGIS Pro without authorizing it.

### arcgis-pro-concurrent-use

Installs ArcGIS Pro and configures it with an existing ArcGIS License Manager.

> The concurrent use license must be either already authorized via License Manager or needs to be done manually.

Required attributes changes:

* arcgis.pro.esri_license_host - ArcGIS License Server host name

### arcgis-pro-single-use

Installs ArcGIS Pro with single use license.

Required attributes changes:

* arcgis.pro.authorization_file - ArcGIS Pro authorization file path

### arcgis-pro-named-user

Installs ArcGIS Pro with named user license.

### ms-dotnet-s3files

Downloads Microsoft .NET Framework 4.8 setups archive from S3 bucket.

The role requires AWS Tools for PowerShell to be installed on the machine.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### ms-dotnet-install

Installs Microsoft .NET Framework 4.8.
