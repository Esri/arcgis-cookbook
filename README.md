ArcGIS Cookbook
===============

This cookbook installs and configures ArcGIS for Server and ArcGIS for Desktop.

Requirements
------------

### Supported ArcGIS software
* ArcGIS 10.4/10.4.1 Server
* ArcGIS 10.4/10.4.1 Data Store
* Portal for ArcGIS 10.4/10.4.1
* ArcGIS 10.4/10.4.1 Web Adaptor (IIS/Java) 
* ArcGIS 10.4/10.4.1 GeoEvent Extension for Server
* ArcGIS 10.4/10.4.1 for Desktop (Windows only)
* ArcGIS 10.4/10.4.1 License Manager 
* ArcGIS Pro 1.1/1.2 (Windows only)

### Platforms
* Windows 7
* Windows 8 (8.1)
  - 8.1 requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Ubuntu 14.04 (when deploying ArcGIS for Server on Amazon Web Services)
* Rhel 6.5, 7.0

### Dependencies
The following cookbooks are required:
* hostsfile
* limits
* authbind
* iptables
* windows
* ms_dotnet
* openssl

Attributes
----------
* `node['arcgis']['version']` = ArcGIS version. Default value is `10.4`.
* `node['arcgis']['run_as_user']` = Account used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default account name is `arcgis`.
* `node['arcgis']['run_as_password']` = Password for the account used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default value is`Pa$$w0rdPa$$w0rd`.
* `node['arcgis']['server']['wa_name']` = The name of the web adaptor used for ArcGIS Server. Default name is `server`.
* `node['arcgis']['server']['domain_name']` = ArcGIS Server domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['server']['local_url']` = ArcGIS Server local URL. Default URL is `http://localhost:6080/arcgis`.
* `node['arcgis']['server']['url']` = ArcGIS Server public URL. Default URL is `https://<server domain name>/<server Web Adaptor name>`.
* `node['arcgis']['server']['primary_server_url']` = URL of ArcGIS Server site to join. Default is `nil`.
* `node['arcgis']['server']['admin_username']` = Primary ArcGIS Server administrator user name. Default user name is `admin`.
* `node['arcgis']['server']['admin_password']` = Primary ArcGIS Server administrator password. Default value is `changeit`.
* `node['arcgis']['server']['directories_root']` = ArcGIS Server root directory. Default Windows directory is `C:\arcgisserver`; default Linux directory is `/mnt/arcgisserver`.
* `node['arcgis']['server']['setup']` = The location of the ArcGIS Server setup executable. Default location on Windows is `C:\Temp\ArcGISServer\Setup.exe`; default location on Linux is `/tmp/server-cd/Setup`.
* `node['arcgis']['server']['install_dir']` = ArcGIS Server installation directory. By default, ArcGIS Server is installed to  `%ProgramW6432%\ArcGIS\Server` on Windows machines and `/` on Linux machines.
* `node['arcgis']['server']['authorization_file']` = ArcGIS Server authorization file path. Default location and authorization file is `C:\Temp\server_license.prvc` on Windows and `/tmp/server_license.prvc` on Linux.
* `node['arcgis']['server']['authorization_file_version']` = ArcGIS Server authorization file version. Default version is `10.3`.
* `node['arcgis']['server']['managed_database']` = ArcGIS Server's managed database connection string. By default, this value is `nil`.
* `node['arcgis']['server']['replicated_database']` = ArcGIS Server's replicated geodatabase connection string. By default, this value is `nil`.
* `node['arcgis']['server']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['keystore_password']` = Keystore file password for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['cert_alias']` = SSL certificate alias for ArcGIS Server. Default alias is composed of these values: `node['arcgis']['server']['domain_name']`.
* `node['arcgis']['server']['system_properties']` = ArcGIS Server system properties. Default value is `{}`. 
* `node['arcgis']['web_adaptor']['admin_access']` = Indicates if ArcGIS Server Manager and Admin API will be available through the web adaptor <true|false>. Default value is `false`.
* `node['arcgis']['portal']['domain_name']` = Portal for ArcGIS domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['portal']['wa_name']` = The web adaptor name for Portal for ArcGIS., Default name is `portal`.
* `node['arcgis']['portal']['local_url']` = Portal for ArcGIS local URL. Default URL is `https://<portal domain name>:7443/arcgis`.
* `node['arcgis']['portal']['url']` = Portal for ArcGIS public URL. Default URL is `https://<portal domain name>/<portal Web Adaptor name>`.
* `node['arcgis']['portal']['private_url']` = Portal for ArcGIS private URL. Default URL is `https://<portal domain name>:7443/arcgis`.
* `node['arcgis']['portal']['web_context_url']` = Portal for ArcGIS web context URL. By default, this is `nil`.
* `node['arcgis']['portal']['primary_machine_url']` = URL of primary Portal for ArcGIS machine. By default, this is `nil`.
* `node['arcgis']['portal']['admin_username']` = Initial portal administrator user name. Default user name is `admin`.
* `node['arcgis']['portal']['admin_password']` = Initial portal administrator password. Default password is `changeit`.
* `node['arcgis']['portal']['admin_email']` = Initial portal administrator e-mail. Default email is `admin@mydomain.com`.
* `node['arcgis']['portal']['admin_full_name']` = Initial portal administrator full name. Default full name is `Administrator`.
* `node['arcgis']['portal']['admin_description']` = Initial portal administrator description. Default description is `Initial portal account administrator`.
* `node['arcgis']['portal']['security_question']` = Security question. Default question is `Your favorite ice cream flavor?`
* `node['arcgis']['portal']['security_question_answer']` = Security question answer. Default answer is `bacon`.
* `node['arcgis']['portal']['setup']` = Portal for ArcGIS setup path. Default location is `C:\Temp\ArcGISPortal\Setup.exe` on Windows and `/tmp/portal-cd/Setup` on Linux.
* `node['arcgis']['portal']['install_dir']` = Portal for ArcGIS installation directory. By default, Portal for ArcGIS is installed to `%ProgramW6432%\ArcGIS\Portal` on Windows machines and `/` on Linux machines.
* `node['arcgis']['portal']['content_dir']` = Portal for ArcGIS content directory. Default directory is `C:\arcgisportal\content` on Windows and `/arcgis/portal/usr/arcgisportal/content` on Linux.
* `node['arcgis']['portal']['authorization_file']` = Portal for ArcGIS authorization file path. Default location and file name is `C:\Temp\portal_license.prvc` on Windows and `/tmp/portal_license.prvc` on Linux.
* `node['arcgis']['portal']['authorization_file_version']` = Portal for ArcGIS authorization file version. Default value is `10.4`.
* `node['arcgis']['portal']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['keystore_password']` = Keystore file password for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['cert_alias']` = SSL certificate alias for Portal for ArcGIS. Default alias is composed of these values:`node['arcgis']['portal']['domain_name']`.
* `node['arcgis']['web_adaptor']['setup']` = Location of ArcGIS Web Adaptor setup executable. Default location is `C:\Temp\WebAdaptorIIS\Setup.exe` on Windows and `/tmp/web-adaptor-cd/Setup` on Linux.
* `node['arcgis']['web_adaptor']['install_dir']` = ArcGIS Web Adaptor installation directory. By default, ArcGIS Web Adaptor is installed to `` on Windows and `/` on Linux.
* `node['arcgis']['data_store']['data_dir']` = ArcGIS Data Store data directory. Default location is `C:\arcgisdatastore\data` on Windows and `/mnt/arcgisdatastore/data` on Linux.
* `node['arcgis']['data_store']['setup']` = Location of ArcGIS Data Store setup executable. Default location is `C:\Temp\ArcGISDataStore\Setup.exe` on Windows and `/tmp/tmp/data-store-cd/Setup` on Linux.
* `node['arcgis']['data_store']['install_dir']` = ArcGIS Data Store installation directory. By default, ArcGIS Data Store is installed to `%ProgramW6432%\ArcGIS\DataStore` on Windows and `/` on Linux.
* `node['arcgis']['data_store']['preferredidentifier']` = ArcGIS Data Store preferred identifier method <hostname|ip>. Default method used is `hostname`.
* `node['arcgis']['data_store']['types']` = Comma-separated list of ArcGIS Data Store types to be created, <relational|tileCache|spatiotemporal>. By default, `tileCache,relational` is used.
* `node['arcgis']['iis']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['iis']['keystore_password']` = Password for keystore file with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['pro']['setup']` = The location of ArcGIS Pro setup msi. Default location is `C:\Temp\ArcGISPro\ArcGISPro.msi`.
* `node['arcgis']['pro']['install_dir']` = ArcGIS Pro installation directory. Default installation directory is `%ProgramFiles%\ArcGIS\Pro`.
* `node['arcgis']['pro']['blockaddins']` = Configures the types of Add-ins that ArcGIS Pro will load. Default value is `#0`.
* `node['arcgis']['pro']['allusers']` = Defines installation context of ArcGIS Pro, 1 - per machine and 2 - per user. Default value is '2'.
* `node['arcgis']['desktop']['setup']` = The location of ArcGIS for Desktop setup executable. Default location is `C:\Temp\ArcGISDesktop\Setup.exe`.
* `node['arcgis']['desktop']['install_dir']` = ArcGIS for Desktop installation directory. By default, ArcGIS for Desktop is installed to `%ProgramFiles(x86)%\ArcGIS`.
* `node['arcgis']['desktop']['install_features']` = Comma-separated list of ArcGIS for Desktop features to install. Default value is `ALL`.
* `node['arcgis']['desktop']['authorization_file']` = ArcGIS for Desktop authorization file path. Default location and file name are `C:\\Temp\\license.ecp`.
* `node['arcgis']['desktop']['authorization_file_version']` = ArcGIS for Desktop authorization file version. Default value is `10.4`.
* `node['arcgis']['desktop']['esri_license_host']` = Hostname of ArcGIS License Manager. Default hostname is `%COMPUTERNAME%`.
* `node['arcgis']['desktop']['software_class']` = ArcGIS for Desktop software class <Viewer|Editor|Professional>. Default value is `Viewer`.
* `node['arcgis']['desktop']['seat_preference']` = ArcGIS for Desktop license seat preference <Fixed|Float>. Default value is `Fixed`.
* `node['arcgis']['licensemanager']['setup']` = The location of ArcGIS License Manager setup executable. Default location is `C:\Temp\ArcGISLicenseManager\Setup.exe` on Windows, `/tmp/licensemanager-cd/Setup` on Linux.
* `node['arcgis']['licensemanager']['install_dir']` = ArcGIS License Manager installation directory. By default, the license manager is installed to `%ProgramFiles(x86)%\ArcGIS` on Windows and `/` on Linux.
* `node['arcgis']['geoevent']['authorization_file']1` = ArcGIS GeoEvent Extension for Server authorization file path. Default value is ``.
* `node['arcgis']['geoevent']['authorization_file_version']` = ArcGIS GeoEvent Extension for Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['geoevent']['setup']` = The location of ArcGIS GeoEvent Extension for Server setup executable. Default location is `C:\Temp\ArcGIS_GeoEventExtension\\setup.exe` on Windows and `/tmp/geo-event-cd/Setup.sh` on Linux.
* `node['arcgis']['hosts']` = Hostname to IP address mappings to be added to /etc/hosts file. Default value is `{}`.


Recipes
-------
### arcgis::hosts
Creates entries in /etc/hosts file for the specified hostname to IP address map.

### arcgis::system
Configures system requirements for web GIS software by invoking ':system' actions for ArcGIS Server, ArcGIS Data Store, Portal for ArcGIS, and ArcGIS Web Adaptor resources, includes arcgis::hosts recipe.

### arcgis::all_installed
Installs all ArcGIS for Server and ArcGIS for Desktop software supported by the cookbook.

### arcgis::webgis_installed
Installs ArcGIS for Server, Portal for ArcGIS, ArcGIS Data Store, and ArcGIS Web Adaptors for server and portal.

### arcgis::all_uninstalled
Uninstalls all ArcGIS 10.4 software.

### arcgis::clean
Deletes local directories created by ArcGIS for Server, Portal for ArcGIS, and ArcGIS Data Store.

### arcgis::authbind
Configures authbind for Apache Tomcat user (for Debian Linux family).

### arcgis::iptables
Configures iptables to forward ports 80/443 to 8080/8443.

### arcgis::iis
Enables IIS, installs features required by ArcGIS Web Adaptor IIS, configures HTTPS, and starts IIS.

### arcgis::server
Installs and configures ArcGIS for Server site.

### arcgis::server_node
Installs ArcGIS Server on the machine and joins an existing site.

### arcgis::server_wa
Installs ArcGIS Web Adaptor and configures it with ArcGIS Server. IIS or Java application server such as Tomcat must be installed and configured before installing ArcGIS Web Adaptor.

### arcgis::portal
Installs and configures Portal for ArcGIS.

### arcgis::portal_wa
Installs ArcGIS Web Adaptor and configures it with Portal for ArcGIS. IIS or Java application server such as Tomcat must be installed and configured before installing ArcGIS Web Adaptor.

### arcgis::portal_standby
Installs and configures Portal for ArcGIS on standby machine

### arcgis::datastore
Installs and configures ArcGIS Data Store on primary machine.

### arcgis::datastore_standby
Installs and configures ArcGIS Data Store on standby machine.

### arcgis::federation
Registers and federates ArcGIS Server with Portal for ArcGIS.

### arcgis::pro
Installs ArcGIS Pro.

### arcgis::desktop
Installs and configures ArcGIS for Desktop.

### arcgis::licensemanager
Installs and configures ArcGIS License Manager.

### arcgis::geoevent
Installs and configures ArcGIS GeoEvent Extension for Server.


Usage
-----
node-windows.json (Web GIS on single Windows machine)

```javascript
{
  "arcgis" : {
    "run_as_user":"arcgis",
    "run_as_password":"Run_As_Pa$$w0rd",
    "iis" : {
       "keystore_file":"C:\\ArcGIS\\keystore.pfx",
       "keystore_password":"changeit"
     },
     "web_adaptor" : {
       "setup":"C:\\ArcGIS\\WebAdaptorIIS\\Setup.exe"
     },
     "data_store" : {
       "setup":"C:\\ArcGIS\\DataStore\\Setup.exe"
     },
     "server" : {
       "domain_name":"agsportalssl.esri.com",
       "admin_username":"admin",
       "admin_password":"admin123",
       "directories_root":"C:\\arcgisserver",
       "setup":"C:\\ArcGIS\\Server\\Setup.exe",
       "authorization_file":"C:\\ArcGIS\\Server.prvc"
     },
     "portal" : {
       "domain_name":"agsportalssl.esri.com",
       "admin_username":"admin",
       "admin_password":"admin123",
       "admin_email":"admin@mydomain.com",
       "security_question":"Your favorite ice cream flavor?",
       "security_question_answer":"vanilla",
       "setup":"C:\\ArcGIS\\Portal\\Setup.exe",
       "authorization_file":"C:\\ArcGIS\\Portal.prvc"
     }
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

node-rhel.json (Web GIS on single Red Hat Enterprise Linux Server machine )

```javascript
{
    "java" : {
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
    "arcgis" : {
      "web_adaptor":{
        "setup":"/arcgis/WebAdaptor/Setup"
      },
      "data_store":{
        "setup":"/arcgis/DataStore/Setup"
      },
      "server":{
        "domain_name":"agsportalssl.esri.com",
        "admin_username":"admin",
        "admin_password":"admin123",
        "directories_root":"/home/ags/arcgis/server/usr/directories",
        "setup":"/arcgis/Server/Setup",
        "authorization_file":"/arcgis/server.prvc"
      },
      "portal":{
        "domain_name":"agsportalssl.esri.com",
        "admin_username":"admin",
        "admin_password":"admin123",
        "admin_email":"admin@mydomain.com",
        "security_question":"Your favorite ice cream flavor?",
        "security_question_answer":"vanilla",
        "setup":"/arcgis/Portal/Setup",
        "authorization_file":"/arcgis/portal.ecp"
      }
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

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2016 Esri

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

[](Esri Tags: ArcGIS Chef Cookbook)
[](Esri Language: Ruby)
