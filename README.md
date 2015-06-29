arcgis Cookbook
===============

This cookbook installs and configures ArcGIS for Server, ArcGIS DataStore, and Portal for ArcGIS on the machine.

Requirements
------------
### ArcGIS 
* ArcGIS for Server 10.3.1 
* ArcGIS DataStore 10.3.1
* Portal for ArcGIS 10.3.1

### Platforms
* Windows Server 2008
* Windows Server 2008 R2
* Windows Server 2012 
* Windows Server 2012 R2
* Ubuntu 14.04
* Rhel 6
* Suse

### Dependencies 
* hostsfile
* limits 
* authbind
* iptables
* windows
* openssl

Attributes
----------
* `node['arcgis']['run_as_user']` - Run as account for Server, Portal, and Data Store, default `arcgis`
* `node['arcgis']['run_as_password']` - Run as account password for Server, Portal, and Data Store, default `Pa$$w0rdPa$$w0rd`
* `node['server']['wa_name']` - Web Adaptor name for server, default `server` 
* `node['server']['domain_name']` - Server domain name, default FQDN of the node
* `node['server']['admin_username']` - Primary server administrator user name, default `admin`
* `node['server']['admin_password']` - Primary server administrator password, default `changeit`
* `node['server']['directories_root']` - Server root directory, default `C:\arcgisserver`, `/mnt/arcgisserver`
* `node['server']['setup']` - Server setup path, default `C:\Temp\ArcGISServer\Setup.exe`, `/tmp/server-cd/Setup`
* `node['server']['install_dir']` - Server installation directory, default `%ProgramW6432%\ArcGIS\Server`, `/`
* `node['server']['authorization_file']` - Server authorization file path, default `C:\Temp\server_license.prvc`, `/tmp/server_license.prvc`
* `node['server']['authorization_file_version']` - Server authorization file version, default `10.3` 
* `node['server']['managed_database']` - Managed GeoDatabase connection string
* `node['server']['replicated_database']` - Replicated GeoDatabase connection string
* `node['portal']['domain_name']` - Portal domin name, default FQDN of the node
* `node['portal']['wa_name']` - Web Adaptor name for portal, default `portal`
* `node['portal']['admin_username']` - Initial portal administrator user name, default `admin`
* `node['portal']['admin_password']` - Initial portal administrator password, default `changeit`
* `node['portal']['admin_email']` - Initial portal administrator e-mail, default `admin@mydomain.com`
* `node['portal']['admin_full_name']` - Initial portal administrator full name, default `Administrator`
* `node['portal']['admin_description']` - Initial portal administrator description, default `Initial portal account administrator`
* `node['portal']['security_question']` - Security question, default `Your favorite ice cream flavor?`
* `node['portal']['security_question_answer']` - Security question answer, default `bacon`
* `node['portal']['setup']` - Portal for ArcGIS setup path, default `C:\Temp\ArcGISPortal\Setup.exe`, `/tmp/portal-cd/Setup`
* `node['portal']['install_dir']` - Portal installation directory, default `%ProgramW6432%\ArcGIS\Portal`, `/`
* `node['portal']['content_dir']` - Portal content directory, default `C:\arcgisportal\content`, `/arcgis/portal/usr/arcgisportal/content`
* `node['portal']['authorization_file']` - Portal authorization file path, default `C:\Temp\portal_license.prvc`, `/tmp/portal_license.prvc`
* `node['portal']['authorization_file_version']` - Portal authorization file version, default `10.3` 
* `node['web_adaptor']['setup']` - Web Adaptor setup path, default `C:\Temp\WebAdaptorIIS\Setup.exe`, `/tmp/web-adaptor-cd/Setup`
* `node['web_adaptor']['install_dir']` - Web Adaptor installation directory
* `node['data_store']['data_dir']` - Data Store data directory, default `C:\arcgisdatastore\data`, `/mnt/arcgisdatastore/data`
* `node['data_store']['setup']` - Data Store setup path, default `C:\Temp\ArcGISDataStore\Setup.exe`, `/tmp/tmp/data-store-cd/Setup`
* `node['data_store']['install_dir']` - Data Store installation directory, default `%ProgramW6432%\ArcGIS\DataStore`, `/`
* `node['data_store']['preferredidentifier']` - Data Store preferred identifier, default `ip`
* `node['iis']['keystore_file']` - Path to PKSC12 keystore file with server SSL certificate
* `node['iis']['keystore_password']` - Keystore password

Usage
-----
### arcgis::system
Creates arcgis user run as account, sets limits, and installs required packages.

### arcgis::all_installed
Installs ArcGIS for Server, Portal for ArcGIS, ArcGIS Data Store, and Web Adaptors for server and portal

### arcgis::authbind
Configures authbind for tomcat user (for Debian linux family).

### arcgis::iptables
Configures iptables to forward ports 80/443 to 8080/8443.

### arcgis::iis
Enables IIS with features required by Web Adaptor, configures HTTPS, and starts IIS

### arcgis::server
Installs and configures ArcGIS for Server.  

### arcgis::server_wa
Installs Web Adaptor and configures it with server. IIS or java application server such as Tomcat must be installed and configured before this. 

### arcgis::portal
Installs and configures Portal for ArcGIS.
 
### arcgis::portal_wa
Installs Web Adaptor and configures it with portal. IIS or java application server such as Tomcat must be installed and configured before this. 

### arcgis::datastore
Installs and configures ArcGIS Data Store.

### arcgis::federation
Registers and federates ArcGIS Server with Portal.
 
node-windows.json
```javascript
{
   "iis" : {
     "keystore_file":"C:\\arcgis\\keystore.pfx",
     "keystore_password":"@Esri2014!"
   },
   "web_adaptor" : {
     "setup":"C:\\arcgis\\ArcGIS_WebAdaptorIIS10.3.1\\Setup.exe"
   },
   "data_store" : {
   	 "setup":"C:\\arcgis\\ArcGIS_DataStore10.3.1\\Setup.exe"
   },
   "server" : {
     "domain_name":"agsportalssl.esri.com",
     "admin_username":"admin",
     "admin_password":"admin123",
     "directories_root":"C:\\arcgisserver",
     "setup" : "C:\\arcgis\\ArcGIS_Server10.3.1\\Setup.exe",
     "authorization_file":"C:\\arcgis\\Server.prvc"
   },
   "portal" : {
     "domain_name":"agsportalssl.esri.com",
     "admin_username":"admin",
     "admin_password":"admin123",
     "admin_email":"admin@mydomain.com",
     "security_question":"Your favorite ice cream flavor?",
     "security_question_answer":"vanilla",
     "setup":"C:\\arcgis\\Portal_for_ArcGIS10.3.1\\Setup.exe",
     "authorization_file":"C:\\arcgis\\Portal.prvc"
   },
   "run_list":[  
      "recipe[arcgis::system]",
      "recipe[iis]",
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
                "setup":"/arcgis/WebAdaptor10.3.1/Setup"
        },
        "data_store":{
                "setup":"/arcgis/DataStore10.3.1/Setup"
        },
        "server":{
                "domain_name":"agsportalssl.esri.com",
                "admin_username":"admin",
                "admin_password":"admin123",
                "directories_root":"/home/ags/arcgis/server/usr/directories",
                "setup":"/arcgis/Server10.3.1/Setup",
                "authorization_file":"/arcgis/server.prvc"
        },
        "portal":{
                "domain_name":"agsportalssl.esri.com",
                "admin_username":"admin",
                "admin_password":"admin123",
                "admin_email":"admin@mydomain.com",
                "security_question":"Your favorite ice cream flavor?",
                "security_question_answer":"vanilla",
                "setup":"/arcgis/Portal10.3.1/Setup", 
                "authorization_file":"/arcgis/portal.prvc"
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

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

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
