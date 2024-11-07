---
layout: default
title: "arcgis-repository cookbook"
category: cookbooks
item: arcgis-repository
version: 5.1.0
latest: true
---

# arcgis-repository cookbook

arcgis-repository cookbook downloads ArcGIS software setup archives from remote to local repositories.

## Supported ArcGIS versions

* 10.9.1
* 11.0
* 11.1
* 11.2
* 11.3
* 11.4

## Platforms

* Windows 10
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu Server 20.04 LTS
* Ubuntu Server 22.04 LTS
* Ubuntu Server 24.04 LTS
* Red Hat Enterprise Linux Server 8
* Red Hat Enterprise Linux Server 9
* SUSE Linux Enterprise Server 15
* Oracle Linux 8
* Oracle Linux 9
* Rocky Linux 8
* Rocky Linux 9
* AlmaLinux 9

## Dependencies

The following cookbooks are required:

* s3_file

## Attributes

* `node['arcgis']['repository']['setups']` = Path to folder with the ArcGIS software setups. Default path is `%USERPROFILE%\Documents` on Windows and `/opt/arcgis` on Linux.
* `node['arcgis']['repository']['archives']` = Local or network ArcGIS software repository path. The default path on Windows is `%USERPROFILE%\\Software\\Esri`. On Linux, it is `/opt/software/esri`.
* `node['arcgis']['repository']['local_archives']` = Local ArcGIS software repository path. The default path on Windows is `%USERPROFILE%\\Software\\Esri`. On Linux, it is `/opt/software/esri`.
* `node['arcgis']['repository']['shared']` = If `true`, a network share is created for the local repository path. Default value is `false`. 
* `node['arcgis']['repository']['patches']` = Path to folder with hot fixes and patches for ArcGIS Enterprise software. The default path on Windows is `%USERPROFILE%\Software\Esri\patches`. On Linux, it is `/opt/software/esri/patches`.
* `node['arcgis']['repository']['server']['url']` = Remote ArcGIS software repository URL. The default URL is `https://devops.arcgis.com/arcgis`.
* `node['arcgis']['repository']['server']['key']` = Remote ArcGIS software repository key.
* `node['arcgis']['repository']['server']['s3bucket']` = Remote ArcGIS software repository S3 bucket name.
* `node['arcgis']['repository']['server']['region']` = Remote ArcGIS software repository S3 bucket region id.
* `node['arcgis']['repository']['server']['aws_access_key']` = AWS access key ID. IAM role credentials are used if access key is not specified.
* `node['arcgis']['repository']['server']['aws_secret_access_key']` = AWS secret access key.
* `node['arcgis']['repository']['files']` = File names mapped to SHA256 checksum and the remote path subfolder attributes. Default value is `nil`.
* `node['arcgis']['repository']['patch_notification']['url']` = ArcGIS patch notification file URL. The default URL is `https://downloads.esri.com/patch_notification/patches.json`.
* `node['arcgis']['repository']['patch_notification']['products']` = An array or ArcGIS product names used to filter downloaded patches. If the array is empty, patches are downloaded for all products. The default value is `[]`.
* `node['arcgis']['repository']['patch_notification']['versions']` = An array of ArcGIS versions used to filter downloaded patches. The default value is `[node['arcgis']['version']]`.
* `node['arcgis']['repository']['patch_notification']['subfolder']` = S3 bucket subfolder with patches. The default value is `nil`.
* `node['arcgis']['repository']['patch_notification']['patches']` = An array of file name patterns used to filter downloaded patches. The default value is `[]`.
* `node['arcgis']['repository']['aws_cli']['msi_url']` = AWS CLI MSI setup URL. The default URL is `https://awscli.amazonaws.com/AWSCLIV2.msi`.
* `node['arcgis']['repository']['aws_cli']['zip_url']` = AWS CLI ZIP setup URL. The default URL is `https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip`.
* `node['arcgis']['repository']['aws_cli']['bin_dir']` = The main `aws` program in the install directory is symbolically linked to the file `aws` in the specified path. The default directory is `/usr/local/bin`.
* `node['arcgis']['repository']['aws_cli']['install_dir']` = AWS CLI installation directory. The default directory is `/usr/local/aws-cli`

## Recipes

### aws_cli

Downloads and installs AWS CLI on the machine.

Attributes used by the recipe:

```json
{
  "arcgis": {
    "repository": {
      "aws_cli": {
        "msi_url": "https://awscli.amazonaws.com/AWSCLIV2.msi",
        "zip_url": "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip",
        "bin_dir": "/usr/local/bin",
        "install_dir": "/usr/local/aws-cli"
      }
    }
  },
  "run_list": [
    "recipe[arcgis-repository::aws_cli]"
  ]
}
```

### default

Calls arcgis-repository::files recipe.

### files

Downloads files from the ArcGIS software repository.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "repository": {
      "local_archives": "C:\\Software\\Archives",
      "server": {
        "url": "https://downloads.arcgis.com",
        "token_service_url": "https://www.arcgis.com/sharing/rest/generateToken",
        "username": "<ArcGIS Online username>",
        "password": "<ArcGIS Online>"
      },
      "files": {
        "<file name>": {
          "subfolder": "<folder>",
          "md5": "<MD5 checksum>",
          "sha256": "<SHA256 checksum>"
        }
      }
    }
  },
  "run_list": [
    "recipe[arcgis-repository::files]"
  ]
}
```

### fileserver

Creates a repository directory and a network share for it if the `arcgis.repository.shared` attribute is set to true.

```json
{
   "arcgis":{
      "repository":{
         "shared": false,
         "local_archives":"C:\\Software\\Archives"
      }
   },
   "run_list":[
      "recipe[arcgis-repository::fileserver]"
   ]
}
```

### patches

Downloads patches for specific ArcGIS products and versions from the ArcGIS software repository.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.1",
    "repository": {
      "local_patches": "C:\\Software\\Archives\\Patches",
      "patch_notification": {
        "products": ["ArcGIS Server"]
      }
    }
  },
  "run_list": [
    "recipe[arcgis-repository::patches]"
  ]
}
```

### s3files

Downloads files from the ArcGIS software repository in S3 to the local repository specified by the node['arcgis']['repository']['local_archives'] attribute.

Attributes used by the recipe:

```JSON
{
   "arcgis":{
      "repository":{
         "local_archives":"C:\\Software\\Archives",
         "server":{
            "region": "us-east-1",
            "s3bucket":"arcgisstore-us-east-1",
            "aws_access_key":"<access_key>",
            "aws_secret_access_key":"<secret_key>"
         },
         "files": {
          "<file name>": {
            "subfolder": "<folder>"
          }
        }
      }
   },
   "run_list":[
      "recipe[arcgis-repository::s3files]"
   ]
}
```

### s3files2

Downloads files from the ArcGIS software repository in S3 to the local repository specified by the node['arcgis']['repository']['local_archives'] attribute.

Downloads patches form S3 subfolder specified by node['arcgis']['repository']['patch_notification']['subfolder'] attribute to the local patches repository specified by node['arcgis]['repository']['local_patches'] attribute.

The s3files2 recipe invokes arcgis-repository::aws_cli recipe to install AWS CLI on the machine.

Attributes used by the recipe:

```JSON
{
   "arcgis":{
      "repository":{
        "local_archives":"C:\\Software\\Archives",
        "local_patches":"C:\\Software\\Archives\\Patches",
        "server":{
          "region": "us-east-1",
          "s3bucket":"arcgisstore-us-east-1",
          "aws_access_key":"<access_key>",
          "aws_secret_access_key":"<secret_key>"
        },
        "patch_notification": {
          "subfolder": "<s3 bucket folder>",
          "patches": [
            "*.msp"
          ]
        },
        "files": {
          "<file name>": {
            "subfolder": "<s3 bucket folder>"
          }
        }
      }
   },
   "run_list":[
      "recipe[arcgis-repository::s3files2]"
   ]
}
```
