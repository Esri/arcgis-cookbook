arcgis-repository cookbook
===============

arcgis-repository cookbook downloads ArcGIS software setup archives from remote to local repositories.

Requirements
------------

### Supported ArcGIS versions

* 10.7
* 10.7.1
* 10.8
* 10.8.1

### Platforms

* Windows 8 (8.1)
* Windows 10
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Ubuntu 14.04, 16.04, 18.04
* Rhel 6.5, 7.0

### Dependencies

The following cookbooks are required:

* s3_file

Attributes
----------

* `node['arcgis']['repository']['setups']` = Path to folder with ArcGIS software setups. Default path is `%USERPROFILE%\Documents` on Windows and `/opt/arcgis` on Linux.
* `node['arcgis']['repository']['archives']` = Local or network ArcGIS software repository path. The default path on windows is `%USERPROFILE%\\Software\\Esri`, on Linux `/opt/software/esri`.
* `node['arcgis']['repository']['local_archives']` = Local ArcGIS software repository path. The default path on windows is `%USERPROFILE%\\Software\\Esri`, on Linux `/opt/software/esri`.
* `node['arcgis']['repository']['patches']` = Path to folder with hot fixes and patches for ArcGIS Enterprise software. The default path on Windows is `%USERPROFILE%\Software\Esri\Patches`,   on Linux is `/opt/software/esri/patches`.
* `node['arcgis']['repository']['server']['url']` = Remote ArcGIS software repository URL. The Default URL is `https://downloads.arcgis.com/dms/rest/download/secured`.
* `node['arcgis']['repository']['server']['key']` = Remote ArcGIS software repository key.
* `node['arcgis']['repository']['server']['s3bucket']` = Remote ArcGIS software repository S3 bucket name.
* `node['arcgis']['repository']['server']['region']` = Remote ArcGIS software repository S3 bucket region id.
* `node['arcgis']['repository']['server']['aws_access_key']` = AWS access key ID. IAM role credentials are used if access key is not specified.
* `node['arcgis']['repository']['server']['aws_secret_access_key']` = AWS secret access key.
* `node['arcgis']['repository']['files']` = file names mapped to SHA256 checksum and the remote path subfolder attributes. Default value is `nil`.

Recipes
-------

### arcgis-repository::default

Downloads files from remote ArcGIS software repository to local repository specified by `node['arcgis']['repository']['local_archives']` attribute.

### arcgis-repository::s3files

Downloads files from ArcGIS software repository in S3 to local repository specified by `node['arcgis']['repository']['local_archives']` attribute.

### arcgis-repository::s3files2

Downloads files from ArcGIS software repository in S3 to local repository using AWS CLI Tools on Linux and AWS Tools for PowerShell on Windows.

Examples
--------

arcgis-repository::default recipe attributes use example. 

```JSON
{
   "arcgis":{
      "repository":{
         "archives":"C:\\Temp\\Software\\Esri",
         "local_archives":"C:\\Temp\\Software\\Esri",
         "server":{
            "url":"https://downloads.arcgis.com/dms/rest/download/secured",
            "key":"<arcgis_online_token>"
         },
         "files":{
            "ArcGIS_DataStore_10124.exe":{
               "subfolder":"software/arcgis_daily/10.7"
            },
            "ArcGIS_Server_10124.exe":{
               "subfolder":"software/arcgis_daily/10.7",
               "checksum":"7CDD2B78BA2C49D4C81882E6211EDCB1BAFCD8BBE64BDF89C2D538BF48F3CDDD"
            }
         }
      }
   },
   "run_list":[
      "recipe[arcgis-repository]"
   ]
}
```

arcgis-repository::s3files recipe use example.

```JSON
{
   "arcgis":{
      "repository":{
         "archives":"/opt/software/esri",
         "local_archives":"/opt/software/esri",
         "server":{
            "s3bucket":"arcgisstore107-us-east-1",
            "aws_access_key":"<access_key>",
            "aws_secret_access_key":"<secret_key>"
         },
         "files":{
            "ArcGIS_DataStore_Linux_107_167719.tar.gz":{
               "subfolder":"10450/setups"
            },
            "ArcGIS_Server_Linux_107_167707.tar.gz":{
               "subfolder":"10450/setups"
            }
         }
      }
   },
   "run_list":[
      "recipe[arcgis-repository::s3files]"
   ]
}
```

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2020 Esri

Licensed under the Apache License, Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [License.txt](https://github.com/Esri/arcgis-cookbook/blob/master/License.txt?raw=true) file.
