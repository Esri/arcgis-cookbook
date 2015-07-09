ArcGIS Cookbook
===============

This cookbook installs and configures ArcGIS for Server, ArcGIS DataStore, and Portal for ArcGIS on the machine.

Requirements
------------
### ArcGIS 
* ArcGIS for Server 10.3.1 
* ArcGIS Data Store 10.3.1
* Portal for ArcGIS 10.3.1
* ArcGIS Web Adaptor 10.3.1

### Platforms
* Windows Server 2008
* Windows Server 2008 R2
* Windows Server 2012 
* Windows Server 2012 R2
* Rhel 6.5, 7.0

### Dependencies 
* hostsfile
* limits 
* authbind
* iptables
* windows
* openssl

Attributes
----------
* `node['arcgis']['run_as_user']` = Account used to run Server, Portal, and Data Store, default `arcgis`
* `node['arcgis']['run_as_password']` = Password for the account used to run Server, Portal, and Data Store, default `Pa$$w0rdPa$$w0rd`
* `node['server']['wa_name']` = The name of the web adaptor used for ArcGIS Server, default `server` 
* `node['server']['domain_name']` = ArcGIS Server domain name; default value is the fully qualified domain name of the node
* `node['server']['admin_username']` = Primary ArcGIS Server administrator user name; default is `admin`
* `node['server']['admin_password']` = Primary ArcGIS Server administrator password; default password is `changeit`
* `node['server']['directories_root']` = ArcGIS Server root directory; default directory is `C:\arcgisserver`, `/mnt/arcgisserver`
* `node['server']['setup']` = The location of the ArcGIS Server setup executable; default location is `C:\Temp\ArcGISServer\Setup.exe`, `/tmp/server-cd/Setup`
* `node['server']['install_dir']` = ArcGIS Server installation directory; default directory is `%ProgramW6432%\ArcGIS\Server`, `/`
* `node['server']['authorization_file']` = ArcGIS Server authorization file path; default path is `C:\Temp\server_license.prvc`, `/tmp/server_license.prvc`
* `node['server']['authorization_file_version']` = ArcGIS Server authorization file version; default version is `10.3` 
* `node['server']['managed_database']` = Connection inofrmation for the ArcGIS Server's managed database
* `node['server']['replicated_database']` = Replicated GeoDatabase connection string
* `node['portal']['domain_name']` = Portal domin name; default the fully qualified domain name of the node
* `node['portal']['wa_name']` = The web adaptor name for Portal; default name is `portal`
* `node['portal']['admin_username']` = Initial portal administrator user name; default name is `admin`
* `node['portal']['admin_password']` = Initial portal administrator password; default password is `changeit`
* `node['portal']['admin_email']` = Initial portal administrator e-mail; default email is `admin@mydomain.com`
* `node['portal']['admin_full_name']` = Initial portal administrator full name; default name is `Administrator`
* `node['portal']['admin_description']` = Initial portal administrator description, default description is `Initial portal account administrator`
* `node['portal']['security_question']` = Security question; default question is `Your favorite ice cream flavor?`
* `node['portal']['security_question_answer']` = Security question answer; default answer is `bacon`
* `node['portal']['setup']` = Portal for ArcGIS setup path; default path is `C:\Temp\ArcGISPortal\Setup.exe`, `/tmp/portal-cd/Setup`
* `node['portal']['install_dir']` = Portal installation directory; default path is `%ProgramW6432%\ArcGIS\Portal`, `/`
* `node['portal']['content_dir']` = Portal content directory; default directory is `C:\arcgisportal\content`, `/arcgis/portal/usr/arcgisportal/content`
* `node['portal']['authorization_file']` = Portal authorization file path; default location is `C:\Temp\portal_license.prvc`, `/tmp/portal_license.prvc`
* `node['portal']['authorization_file_version']` = Portal authorization file version; default version is `10.3` 
* `node['web_adaptor']['setup']` = Location of ArcGIS Web Adaptor setup executable; default location is `C:\Temp\WebAdaptorIIS\Setup.exe`, `/tmp/web-adaptor-cd/Setup`
* `node['web_adaptor']['install_dir']` = ArcGIS Web Adaptor installation directory
* `node['data_store']['data_dir']` = ArcGIS Data Store data directory; default directory is `C:\arcgisdatastore\data`, `/mnt/arcgisdatastore/data`
* `node['data_store']['setup']` = Location of ArcGIS Data Store setup executable; default location is `C:\Temp\ArcGISDataStore\Setup.exe`, `/tmp/tmp/data-store-cd/Setup`
* `node['data_store']['install_dir']` = ArcGIS Data Store installation directory; default directory is `%ProgramW6432%\ArcGIS\DataStore`, `/`
* `node['data_store']['preferredidentifier']` = ArcGIS Data Store preferred identifier method; default is `ip`
* `node['iis']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with server SSL certificate
* `node['iis']['keystore_password']` = Keystore password

Usage
-----
### arcgis::system
Creates user account that will run all ArcGIS software components, sets limits, and installs required packages.

### arcgis::all_installed
Installs ArcGIS for Server, Portal for ArcGIS, ArcGIS Data Store, and ArcGIS Web Adaptors for server and portal

### arcgis::authbind
Configures authbind for Apache Tomcat user (for Debian Linux family).

### arcgis::iptables
Configures iptables to forward ports 80/443 to 8080/8443.

### arcgis::iis
Enables IIS with features required by ArcGIS Web Adaptor IIS, configures HTTPS, and starts IIS

### arcgis::server
Installs and configures ArcGIS for Server.  

### arcgis::server_wa
Installs ArcGIS Web Adaptor and configures it with ArcGIS Server. You must install and condigure an IIS or Java application server such as Tomcat before installing ArcGIS Web Adaptor. 

### arcgis::portal
Installs and configures Portal for ArcGIS.
 
### arcgis::portal_wa
Installs ArcGIS Web Adaptor and configures it with ArcGIS Portal. You must install and condigure an IIS or Java application server such as Tomcat before installing ArcGIS Web Adaptor. 

### arcgis::datastore
Installs and configures ArcGIS Data Store.

### arcgis::federation
Registers and federates ArcGIS Server with Portal.
 
node-windows.json
```javascript
{
   "iis" : {
     "keystore_file":"C:\\ArcGIS10.3.1\\keystore.pfx",
     "keystore_password":"changeit"
   },
   "web_adaptor" : {
     "setup":"C:\\ArcGIS10.3.1\\WebAdaptorIIS\\Setup.exe"
   },
   "data_store" : {
     "setup":"C:\\ArcGIS10.3.1\\DataStore\\Setup.exe"
   },
   "server" : {
     "domain_name":"agsportalssl.esri.com",
     "admin_username":"admin",
     "admin_password":"admin123",
     "directories_root":"C:\\arcgisserver",
     "setup":"C:\\ArcGIS10.3.1\\Server\\Setup.exe",
     "authorization_file":"C:\\ArcGIS10.3.1\\Server.prvc"
   },
   "portal" : {
     "domain_name":"agsportalssl.esri.com",
     "admin_username":"admin",
     "admin_password":"admin123",
     "admin_email":"admin@mydomain.com",
     "security_question":"Your favorite ice cream flavor?",
     "security_question_answer":"vanilla",
     "setup":"C:\\ArcGIS10.3.1\\Portal\\Setup.exe",
     "authorization_file":"C:\\ArcGIS10.3.1\\Portal.prvc"
   },
   "run_list":[  
      "recipe[arcgis::system]",
      "recipe[arcgis::iis]",
      "recipe[arcgis::server]",
      "recipe[arcgis::server_wa]",
      "recipe[arcgis::datastore]",
      "recipe[arcgis::portal]",
      "recipe[arcgis::portal_wa]",
      "recipe[arcgis::federation]"
   ]
}
```

node-rhel.json
```javascript
{
        "java":{
                "install_flavor":"oracle",
                "jdk_version":"7",
                "oracle":{
                        "accept_oracle_download_terms":true
                }
        },
        "tomcat":{
                "base_version":7,
                "port":8080,
                "ssl_port":8443
        },
        "web_adaptor":{
                "setup":"/arcgis10.3.1/WebAdaptor/Setup"
        },
        "data_store":{
                "setup":"/arcgis10.3.1/DataStore/Setup"
        },
        "server":{
                "domain_name":"agsportalssl.esri.com",
                "admin_username":"admin",
                "admin_password":"admin123",
                "directories_root":"/home/ags/arcgis/server/usr/directories",
                "setup":"/arcgis10.3.1/Server/Setup",
                "authorization_file":"/arcgis10.3.1/server.prvc"
        },
        "portal":{
                "domain_name":"agsportalssl.esri.com",
                "admin_username":"admin",
                "admin_password":"admin123",
                "admin_email":"admin@mydomain.com",
                "security_question":"Your favorite ice cream flavor?",
                "security_question_answer":"vanilla",
                "setup":"/arcgis10.3.1/Portal/Setup", 
                "authorization_file":"/arcgis10.3.1/portal.ecp"
        },
        "run_list":[
                "recipe[arcgis::system]",
                "recipe[java]",
                "recipe[iptables]",
                "recipe[arcgis::iptables]",
                "recipe[tomcat]",
                "recipe[arcgis::server]",
                "recipe[arcgis::server_wa]",
                "recipe[arcgis::datastore]",
                "recipe[arcgis::portal]",
                "recipe[arcgis::portal_wa]",
                "recipe[arcgis::federation]"
        ]
}
```

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](/../../issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [License.txt](License.txt?raw=true) file.

[](Esri Tags: ArcGIS Chef Cookbook)
[](Esri Language: Ruby)
