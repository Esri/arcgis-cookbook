arcgis-enterprise cookbook
===============

This cookbook installs and configures ArcGIS Enterprise products, components, and tools.

Requirements
------------

### Supported ArcGIS versions

* 10.7
* 10.7.1
* 10.8
* 10.8.1
* 10.9
* 10.9.1

### Supported ArcGIS software

* ArcGIS Server
* ArcGIS Data Store
* Portal for ArcGIS
* Portal for ArcGIS Web Styles
* ArcGIS Web Adaptor (IIS/Java)

### Platforms

* Windows 8 (8.1). 8.1 requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows 10. Requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu Server 18.04 and 20.04 LTS
* Red Hat Enterprise Linux Server 8
* SUSE Linux Enterprise Server 15
* CentOS Linux 8
* Oracle Linux 8

### Dependencies

The following cookbooks are required:

* arcgis-repository
* hostsfile
* limits
* authbind
* iptables
* windows
* windows_firewall
* ms_dotnet

Attributes
----------

#### General

* `node['arcgis']['version']` = ArcGIS version. Default value is `10.9.1`.
* `node['arcgis']['run_as_user']` = Account used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default account name is `arcgis`.
* `node['arcgis']['run_as_password']` = Password for the account used to run ArcGIS Server, 
Portal for ArcGIS, and ArcGIS Data Store. Default value is`Pa$$w0rdPa$$w0rd`.
* `node['arcgis']['run_as_msa']` = If set to `true` configures ArcGIS Enterprise applications to use windows group managed service account (gMSA). Default setting is `false`.
* `node['arcgis']['hosts']` = Hostname to IP address mappings to be added to /etc/hosts file. Default value is `{}`.
* `node['arcgis']['cache_authorization_files']` = If set to true, the software authorization file is cached on the machine and software authorization is skipped in the subsequent chef runs. Default value is `false`.
* `node['arcgis']['configure_windows_firewall']` = If set to true, Windows firewall is configured for ArcGIS applications as specified by the system requirements. Default value is `false`.
* `node['arcgis']['python']['install_dir']` = Python installation directory. By default Python is installed at `C:\Python27`.
* `node['arcgis']['post_install_script']` = Custom post-installation script path. The default path on Windows is `C:\imageryscripts\deploy.bat`, on Linux is `/arcgis/imageryscripts/deploy.sh`.
* `node['arcgis']['configure_cloud_settings']` = If set to `true`, makes the cookbook use cloud provider specific ArcGIS Enterprise configuration. The default value is `true` if `node['cloud']` is defined or arcgis_cloud_platform environment varible is set to `aws`.
* `node['arcgis']['cloud']['provider']` = Cloud provider. Default value is set `ec2` if arcgis_cloud_platform environment variable is set to `aws` and to `node['cloud']['provider']` attribute value otherwise.

#### File Server

* `node['arcgis']['fileserver']['directories']` = List of local directories created by 'fileserver' recipe. Default list is `[node['arcgis']['server']['local_directories_root'], node['arcgis']['data_store']['local_backup_dir'], node['arcgis']['data_store']['local_backup_dir']/tilecache, node['arcgis']['data_store']['local_backup_dir']/relational, node['arcgis']['portal']['local_content_dir']]`.
* `node['arcgis']['fileserver']['shares']` = List of local directories shared by 'fileserver' recipe. Default list is `[node['arcgis']['server']['local_directories_root'], node['arcgis']['data_store']['local_backup_dir'], node['arcgis']['portal']['local_content_dir']]`.

#### Server

* `node['arcgis']['server']['wa_name']` = The name of the Web Adaptor used for ArcGIS Server. Default name is `server`.
* `node['arcgis']['server']['wa_url']` = URL of the Web Adaptor used for ArcGIS Server. Default name is `https://<FQDN of the machine>/<Server Web Adaptor name>`.
* `node['arcgis']['server']['domain_name']` = ArcGIS Server domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['server']['hostname']` = Host name or IP address of ArcGIS Server machine. Default value is  `''`.
* `node['arcgis']['server']['url']` = ArcGIS Server URL. The default URL is `https://<FQDN of the machine>:6443/arcgis` using the fully qualified domain name of the machine on which Chef is running. If ArcGIS Server and the web adaptor are running on different machines, then this value should be explicitly set.
* `node['arcgis']['server']['private_url']` = ArcGIS Server URL without Web Adaptor. Default URL is `https://<server domain name>:6443/arcgis`.
* `node['arcgis']['server']['primary_server_url']` = URL of ArcGIS Server site to join. Default is `nil`.
* `node['arcgis']['server']['web_context_url']` = ArcGIS server web context URL. By default, this is `'https://<Domain name>/<WA name>`.
* `node['arcgis']['server']['use_join_site_tool']` = Is set to true, join-site command line tool is used to add machine to the site and the default cluster. Default value is `false`.
* `node['arcgis']['server']['admin_username']` = Primary ArcGIS Server administrator user name. Default user name is `admin`.
* `node['arcgis']['server']['admin_password']` = Primary ArcGIS Server administrator password. Default value is `changeit`.
* `node['arcgis']['server']['publisher_username']` = ArcGIS Server publisher user name. Default user name is `node['arcgis']['server']['admin_username']`.
* `node['arcgis']['server']['publisher_password']` = ArcGIS Server publisher password. Default value is `node['arcgis']['server']['admin_password']`.
* `node['arcgis']['server']['directories_root']` = ArcGIS Server root directory. Default Windows directory is `C:\arcgisserver`; default Linux directory is `/arcgis/server/usr`.
* `node['arcgis']['server']['setup']` = The location of the ArcGIS Server setup executable. Default location on Windows is `C:\Temp\ArcGISServer\Setup.exe`; default location on Linux is `/tmp/server-cd/Setup`.
* `node['arcgis']['server']['setup_options']` = Additional ArcGIS Server setup command line options. Default options are `''`.
* `node['arcgis']['server']['lp-setup']` = The location of language pack for ArcGIS Server. Default location is `nil`.
* `node['arcgis']['server']['setup_archive']` = Path to ArcGIS Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['server']['install_dir']` = ArcGIS Server installation directory. By default, ArcGIS Server is installed to  `%ProgramW6432%\ArcGIS\Server` on Windows machines and `/` on Linux machines.
* `node['arcgis']['server']['is_hosting']` = Must be set to true for hosting server. Default value is `true`.
* `node['arcgis']['server']['install_system_requirements']` = If set to true, the required third party libraries are installed on the machine before running ArcGIS Server setup. Default value is `true`.
* `node['arcgis']['server']['configure_autostart']` = If set to true, on Linux the ArcGIS Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['server']['authorization_file']` = ArcGIS Server authorization file path. Default location and authorization file is `C:\Temp\server_license.prvc` on Windows and `/tmp/server_license.prvc` on Linux.
* `node['arcgis']['server']['authorization_file_version']` = ArcGIS Server authorization file version. Default version is `node['arcgis']['version']`.
* `node['arcgis']['server']['authorization_options']` = Additional ArcGIS Server software authorization command line options. Default options are `''`.
* `node['arcgis']['server']['data_items']` = Array of data items that need to be registered with ArcGIS Server. Default value is `[]`.
* `node['arcgis']['server']['managed_database']` = (deprecated) ArcGIS Server's managed database connection string. By default, this value is `nil`.
* `node['arcgis']['server']['replicated_database']` = (deprecated) ArcGIS Server's replicated geodatabase connection string. By default, this value is `nil`.
* `node['arcgis']['server']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['keystore_password']` = Keystore file password for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['cert_alias']` = SSL certificate alias for ArcGIS Server. Default alias is composed of these values: `node['arcgis']['server']['domain_name']`.
* `node['arcgis']['server']['root_cert']` = ArcGIS Server root CA certificate file path. Default value is `''`.
* `node['arcgis']['server']['root_cert_alias']` = ArcGIS Server root CA certificate alias. Default value is `''`.
* `node['arcgis']['server']['system_properties']` = ArcGIS Server system properties. Default value is `{}`.
* `node['arcgis']['server']['log_level']` = ArcGIS Server log level. Default value is `WARNING`.
* `node['arcgis']['server']['log_dir']` = ArcGIS Server log directory. Default value is `C:\arcgisserver\logs` on Windows and `/arcgis/server/usr/logs` on Linux.
* `node['arcgis']['server']['max_log_file_age']` = ArcGIS Server maximum log file age. Default value is `90`.
* `node['arcgis']['server']['config_store_type']` = ArcGIS Server config store type. Default value is `FILESYSTEM`.
* `node['arcgis']['server']['config_store_connection_string']` = ArcGIS Server config store type. Default value is `C:\arcgisserver\config-store` on Windows and `/arcgis/server/usr/config-store` on Linux.
* `node['arcgis']['server']['config_store_connection_secret']` = ArcGIS Server config store type secret. Default value is `nil`.
* `node['arcgis']['server']['services']` = An array of ArcGIS Server services to be published. Default value is `{}`.
* `node['arcgis']['server']['security']['user_store_config']` = User store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['server']['security']['role_store_config']` = Role store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['server']['security']['privileges']` = Privileges to user roles assignments `{'PUBLISH' => [], 'ADMINISTER' => []}`
* `node['arcgis']['server']['soc_max_heap_size']` = SOC maximum heap size in megabytes. Default value is `64`.
* `node['arcgis']['server']['protocol']` = Protocol used by server. Default value is `HTTPS`.
* `node['arcgis']['server']['authentication_mode']` = Server authentication mode. Default value is `ARCGIS_TOKEN`.
* `node['arcgis']['server']['authentication_tier']` = Server authentication tier. Default value is `GIS_SERVER`.
* `node['arcgis']['server']['hsts_enabled']` = HTTP Strict Transport Security enabled. Default value is `false`.
* `node['arcgis']['server']['virtual_dirs_security_enabled']` = Security for virtual directories enabled. Default value is `false`.
* `node['arcgis']['server']['allow_direct_access']` = Allow direct access to server. Default value is `true`.
* `node['arcgis']['server']['allowed_admin_access_ips']` = A comma separated list of client machine IP addresses that are allowed access to ArcGIS Server. `''`.
* `node['arcgis']['server']['ports]` = Ports opened in Windows firewall for ArcGIS Server. Default ports are `1098,4000-4004,6006,6080,6099,6443`.
* `node['arcgis']['server']['geoanalytics_ports]` = Ports opened in Windows firewall for ArcGIS GeoAnalytics Server. Default ports are `2181,2182,2190,7077,12181,12182,12190,56540-56545`.
* `node['arcgis']['server']['pull_license]` = If set to `true`, server_node recipe pulls ArcGIS Server license from other server machines in the site. The default value is `false`.

#### Web Adaptor

* `node['arcgis']['web_adaptor']['admin_access']` = Indicates if ArcGIS Server Manager and Admin API will be available through the Web Adaptor <true|false>. Default value is `false`.
* `node['arcgis']['web_adaptor']['setup']` = Location of ArcGIS Web Adaptor setup executable. Default location is `C:\Temp\WebAdaptorIIS\Setup.exe` on Windows and `/tmp/web-adaptor-cd/Setup` on Linux.
* `node['arcgis']['web_adaptor']['setup_options']` = Additional Web Adaptor setup command line options. Default options are `''`.
* `node['arcgis']['web_adaptor']['lp-setup']` = The location of language pack for ArcGIS Web Adaptor. Default location is `nil`.
* `node['arcgis']['web_adaptor']['setup_archive']` = Path to ArcGIS Web Adaptor setup archive. Default value depends on `node['arcgis']['version']` attribute value. 
* `node['arcgis']['web_adaptor']['install_dir']` = ArcGIS Web Adaptor installation directory (Linux only). By default, ArcGIS Web Adaptor is installed to `/` on Linux.
* `node['arcgis']['web_adaptor']['reindex_portal_content']` = If set to `true`, Web Adaptor registration reindexes Portal for ArcGIS content. Default value is `true`.

#### Portal

* `node['arcgis']['portal']['domain_name']` = Portal for ArcGIS domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['portal']['wa_name']` = The Web Adaptor name for Portal for ArcGIS., Default name is `portal`.
* `node['arcgis']['portal']['wa_url']` = URL of the Web Adaptor for Portal for ArcGIS., Default name is `https://<FQDN of the machine>/<Portal Web Adaptor name>`.
* `node['arcgis']['portal']['url']` = Portal for ArcGIS URL. The default URL is `https://<FQDN of the machine>:7443/arcgis` using the fully qualified domain name of the machine on which Chef is running. If Portal for ArcGIS and the web adaptor are running on different machines, then this value should be explicitly set.
* `node['arcgis']['portal']['private_url']` = Portal for ArcGIS private URL. Default URL is `https://<portal domain name>:7443/arcgis`.
* `node['arcgis']['portal']['primary_machine_url']` = URL of primary Portal for ArcGIS machine. By default, this is `nil`.
* `node['arcgis']['portal']['admin_username']` = Initial portal administrator user name. Default user name is `admin`.
* `node['arcgis']['portal']['admin_password']` = Initial portal administrator password. Default password is `changeit`.
* `node['arcgis']['portal']['admin_email']` = Initial portal administrator e-mail. Default email is `admin@mydomain.com`.
* `node['arcgis']['portal']['admin_full_name']` = Initial portal administrator full name. Default full name is `Administrator`.
* `node['arcgis']['portal']['admin_description']` = Initial portal administrator description. Default description is `Initial portal account administrator`.
* `node['arcgis']['portal']['security_question']` = Security question. Default question is `Your favorite ice cream flavor?`
* `node['arcgis']['portal']['security_question_answer']` = Security question answer. Default answer is `bacon`.
* `node['arcgis']['portal']['setup']` = Portal for ArcGIS setup path. Default location is `C:\Temp\ArcGISPortal\Setup.exe` on Windows and `/tmp/portal-cd/Setup` on Linux.
* `node['arcgis']['portal']['setup_options']` = Additional Portal for ArcGIS setup command line options. Default options are `''`.
* `node['arcgis']['portal']['lp-setup']` = The location of language pack for Portal for ArcGIS. Default location is `nil`.
* `node['arcgis']['portal']['setup_archive']` = Path to Portal for ArcGIS setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['portal']['install_dir']` = Portal for ArcGIS installation directory. By default, Portal for ArcGIS is installed to `%ProgramW6432%\ArcGIS\Portal` on Windows machines and `/` on Linux machines.
* `node['arcgis']['portal']['install_system_requirements']` = If set to true, the required third party libraries are installed on the machine before running Portal for ArcGIS setup. Default value is `true`.
* `node['arcgis']['portal']['configure_autostart']` = If set to true, on Linux the Portal for ArcGIS is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['portal']['data_dir']` = Data directory path used by Portal for ArcGIS setup. The path must be a local directory, not a shared network directory. Dafault path on Windows is `C:\arcgisportal`, on Linux is `/arcgis/portal/usr/arcgisportal/`.
* `node['arcgis']['portal']['content_dir']` = Portal for ArcGIS content directory. Default directory is `C:\arcgisportal\content` on Windows and `/arcgis/portal/usr/arcgisportal/content` on Linux.
* `node['arcgis']['portal']['authorization_file']` = Portal for ArcGIS authorization file path. Default location and file name is `C:\Temp\portal_license.prvc` on Windows and `/tmp/portal_license.prvc` on Linux.
* `node['arcgis']['portal']['authorization_file_version']` = Portal for ArcGIS authorization file version. Default value is `10.4`.
* `node['arcgis']['portal']['user_license_type_id']` = Portal for ArcGIS administrator user license type Id.
* `node['arcgis']['portal']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['keystore_password']` = Keystore file password for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['cert_alias']` = SSL certificate alias for Portal for ArcGIS. Default alias is composed of these values:`node['arcgis']['portal']['domain_name']`.
* `node['arcgis']['portal']['hostname']` = Host name or IP address of Portal for ArcGIS machine specified in hostname.properties file. Default value is  `''`.
* `node['arcgis']['portal']['hostidentifier']` = Host name or IP address of Portal for ArcGIS machine specified in hostidentifier.properties file. Default value is  `node['arcgis']['portal']['hostname']`.
* `node['arcgis']['portal']['preferredidentifier']` = Portal for ArcGIS preferred identifier method <hostname|ip>. Default method used is `hostname`.
* `node['arcgis']['portal']['content_store_type']` = Portal for ArcGIS content store type <FileStore|CloudStore>. Default value is `FileStore`.
* `node['arcgis']['portal']['content_store_provider']` = Portal for ArcGIS content store provider <Amazon|FileSystem>. Default value is `FileSystem`.
* `node['arcgis']['portal']['content_store_connection_string']` = Portal for ArcGIS content store connection string. Default connection string is `node['arcgis']['portal']['content_dir']`.
* `node['arcgis']['portal']['object_store']` = Portal for ArcGIS content store container such as S3 bucket name. Default value is `nil`.
* `node['arcgis']['portal']['log_level']` = Portal for ArcGIS log level. Default value is `WARNING`.
* `node['arcgis']['portal']['log_dir']` = Portal for ArcGIS log directory. Default value is `C:\arcgisportal\logs` on Windows and `/arcgis/portal/usr/arcgisportal/logs` on Linux.
* `node['arcgis']['portal']['max_log_file_age']` = Portal for ArcGIS  maximum log file age. Default value is `90`.
* `node['arcgis']['portal']['upgrade_backup']` = Backup Portal for ArcGIS content during upgrade. Default value is `true`.
* `node['arcgis']['portal']['upgrade_rollback']` = Rollback Portal for ArcGIS upgrade in case of failure. Default value is `true`.
* `node['arcgis']['portal']['root_cert']` = Portal for ArcGIS root certificate. Default value is `''`.
* `node['arcgis']['portal']['root_cert_alias']` = Portal for ArcGIS root certificate alias. Default value is `''`.
* `node['arcgis']['portal']['allssl']` = Portal for ArcGIS run in all SSL mode or not. Default value is `false`.
* `node['arcgis']['portal']['security']['user_store_config']` = User store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['portal']['security']['role_store_config']` = Role store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['portal']['system_properties']` = Portal for ArcGIS system properties. Default value is `{}`.
* `node['arcgis']['portal']['ports']` = Ports opened in Windows firewall for Portal for ArcGIS. Default ports are `5701,5702,5703,7080,7443,7005,7099,7199,7120,7220,7654`.

#### Web Styles

* `node['arcgis']['webstyles']['setup']` = ArcGIS Web Styles setup path.
* `node['arcgis']['webstyles']['setup_options']` = Additional ArcGIS Web Styles setup command line options. Default options are `''`.
* `node['arcgis']['webstyles']['setup_archive']` = ArcGIS Web Styles setup archive path. Default value depends on `node['arcgis']['version']` attribute value.

#### Data Store

* `node['arcgis']['data_store']['data_dir']` = ArcGIS Data Store data directory. Default location is `C:\arcgisdatastore` on Windows and `/arcgis/datastore/usr/arcgisdatastore` on Linux.
* `node['arcgis']['data_store']['backup_dir']` = ArcGIS Data Store backup directory. Default location is `C:\arcgisbackup` on Windows and `/arcgis/datastore/usr/arcgisbackup` on Linux.
* `node['arcgis']['data_store']['setup']` = Location of ArcGIS Data Store setup executable. Default location is `C:\Temp\ArcGISDataStore\Setup.exe` on Windows and `/tmp/tmp/data-store-cd/Setup` on Linux.
* `node['arcgis']['data_store']['setup_options']` = Additional ArcGIS Data Store setup command line options. Default options are `''`.
* `node['arcgis']['data_store']['lp-setup']` = The location of language pack for ArcGIS Data Store. Default location is `nil`.
* `node['arcgis']['data_store']['setup_archive']` = Path to ArcGIS Data Store setup archive. Default value depends on `node['arcgis']['version']` attribute value. 
* `node['arcgis']['data_store']['install_dir']` = ArcGIS Data Store installation directory. By default, ArcGIS Data Store is installed to `%ProgramW6432%\ArcGIS\DataStore` on Windows and `/` on Linux.
* `node['arcgis']['data_store']['install_system_requirements']` = If set to true, the required third party libraries are installed on the machine before running ArcGIS Data Store setup. Default value is `true`.
* `node['arcgis']['data_store']['configure_autostart']` = If set to true, on Linux the ArcGIS Data Store is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['data_store']['hostidentifier']` = Host name or IP address of ArcGIS Data Store machine. Default value is  `''`.
* `node['arcgis']['data_store']['preferredidentifier']` = ArcGIS Data Store preferred identifier method <hostname|ip>. Default method used is `hostname`.
* `node['arcgis']['data_store']['types']` = Comma-separated list of ArcGIS Data Store types to be created, <relational|tileCache|spatiotemporal>. By default, `tileCache,relational` is used.
* `node['arcgis']['data_store']['mode']` = Tile cache ArcGIS Data Store mode, <|primaryStandby|cluster>. Supported from ArcGIS Data Store 10.8.1. The default value is empty string `` that means use the mode default for the ArcGIS Data Store version or the currently configured mode.
* `node['arcgis']['data_store']['relational']['backup_type']` = Type of location to use for relational Data Store backups <fs|s3|azure|none>. The default value is `fs`.
* `node['arcgis']['data_store']['relational']['backup_location']` = Relational Data Store backup location. The default location is `node['arcgis']['data_store']['backup_dir']/relational`).
* `node['arcgis']['data_store']['tilecache']['backup_type']` = Type of location to use for tile cache Data Store backups <fs|s3|azure|none>. The default value is `fs`.
* `node['arcgis']['data_store']['tilecache']['backup_location']` =  = Tile cache Data Store backup location. The default location is `node['arcgis']['data_store']['backup_dir']/tilecache`).
* `node['arcgis']['data_store']['force_remove_machine']` = Specify true only if ArcGIS Server site is unavailable when ArcGIS Data Store machine is removed. Default value is `false`.
* `node['arcgis']['data_store']['ports']` = Ports opened in windows firewall for ArcGIS Data Store. Default ports are `2443,4369,9220,9320,9876,9900,29079-29090`.

#### Linux Web Server

* `node['arcgis']['web_server']['webapp_dir']` = Path to web server's web application directory (eg. /opt/tomcat/webapps). Default value is `''`

Recipes
-------

### arcgis-enterprise::authbind (DEPRECATED)

Configures authbind for Apache Tomcat user (for Debian Linux family).

### arcgis-enterprise::clean

Deletes local directories created by ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store.

### arcgis-enterprise::datastore

Installs and configures ArcGIS Data Store on primary machine.

### arcgis-enterprise::datastore_standby

Installs and configures ArcGIS Data Store on standby machine.

### arcgis-enterprise::disable_geoanalytics

Resets the function of the federated server in the Portal for ArcGIS.

### arcgis-enterprise::disable_imagehosting

Resets the function of the federated server in the Portal for ArcGIS.

### arcgis-enterprise::disable_loopback_check

Enables filesharing via a DNS Alias

### arcgis-enterprise::disable_rasteranalytics

Resets the function of the federated server in the Portal for ArcGIS.

### arcgis-enterprise::egdb (deprecated)

Registers enterprise geodatabases with ArcGIS Server.

### arcgis-enterprise::enable_geoanalytics

Registers ArcGIS Server with GeoAnalytics function to the Portal for ArcGIS.

### arcgis-enterprise::enable_imagehosting

Registers ArcGIS Server with ImageHosting function to the Portal for ArcGIS.

### arcgis-enterprise::enable_rasteranalytics

Registers ArcGIS Server with RasterAnalytics function to the Portal for ArcGIS.

### arcgis-enterprise::federation

Registers and federates ArcGIS Server with Portal for ArcGIS.

### arcgis-enterprise::fileserver

Creates and shares directories on file server machine.

### arcgis-enterprise::hosts

Creates entries in /etc/hosts file for the specified hostname to IP address map.

### arcgis-enterprise::install_datastore

Installs ArcGIS Data Store on the machine.

### arcgis-enterprise::install_portal

Installs Portal for ArcGIS on the machine.

### arcgis-enterprise::install_portal_wa

Installs ArcGIS Web Adaptor instance for Portal for ArcGIS.

### arcgis-enterprise::install_server

Installs ArcGIS Server on the machine.

### arcgis-enterprise::install_server_wa

Installs ArcGIS Web Adaptor instance for ArcGIS Server.

### arcgis-enterprise::lp-install

Installs language packs for ArcGIS Server software.

### arcgis-enterprise::patches

Installs hot fixes and patches for ArcGIS Enterprise software.

### arcgis-enterprise::portal

Installs and configures Portal for ArcGIS.

### arcgis-enterprise::portal_security

Configures Portal for ArcGIS identity stores and assigns privileges to roles.

### arcgis-enterprise::portal_standby

Installs and configures Portal for ArcGIS on standby machine

### arcgis-enterprise::portal_wa

Installs ArcGIS Web Adaptor and configures it with Portal for ArcGIS. IIS or Java application server such as Tomcat must be installed and configured before installing ArcGIS Web Adaptor.

### arcgis-enterprise::post_install

Executes custom post-installation script if it exists.

### arcgis-enterprise::remove_datastore_machine

Removes machine from ArcGIS Data Store.

### arcgis-enterprise::server

Installs and configures ArcGIS Server site.

### arcgis-enterprise::server_data_items

Registers data items with ArcGIS Server.

### arcgis-enterprise::server_node

Installs ArcGIS Server on the machine and joins an existing site.

### arcgis-enterprise::server_security

Configures ArcGIS Server identity stores and assigns privileges to roles.

### arcgis-enterprise::server_wa

Installs ArcGIS Web Adaptor and configures it with ArcGIS Server. IIS or Java application server such as Tomcat must be installed and configured before installing ArcGIS Web Adaptor.

### arcgis-enterprise::services

Publishes services to ArcGIS Server.

### arcgis-enterprise::start_datastore

Starts ArcGIS Data Store on the machine.

### arcgis-enterprise::start_portal

Starts Portal for ArcGIS on the machine.

### arcgis-enterprise::start_server

Starts ArcGIS Server on the machine.

### arcgis-enterprise::stop_datastore

Stops ArcGIS Data Store on the machine.

### arcgis-enterprise::stop_portal

Stops Portal for ArcGIS on the machine.

### arcgis-enterprise::stop_server

Stops ArcGIS Server on the machine.

### arcgis-enterprise::stop_machine

Stops server machine in the ArcGIS Server site.

### arcgis-enterprise::system

Configures system requirements for ArcGIS Enterprise software by invoking ':system' actions for ArcGIS Server, ArcGIS Data Store, Portal for ArcGIS, and ArcGIS Web Adaptor resources, includes arcgis::hosts recipe.

### arcgis-enterprise::enterprise_installed

Installs ArcGIS Server, Portal for ArcGIS, ArcGIS Data Store, and ArcGIS Web Adaptors for server and portal.

### arcgis-enterprise::enterprise_uninstalled

Uninstalls ArcGIS Server, Portal for ArcGIS, ArcGIS Data Store, and ArcGIS Web Adaptors for server and portal.

### arcgis-enterprise::unfederate_server

Unfederates server from Portal for ArcGIS.

### arcgis-enterprise::unregister_machine

Unregisters the local server machine from the ArcGIS Server site.

### arcgis-enterprise::unregister_machines

Unregisters from the ArcGIS Server site all the server machines except for the local.

### arcgis-enterprise::unregister_stopped_machines

Unregisters all unavailable server machines in 'default' cluster from the ArcGIS Server site.

### arcgis-enterprise::unregister_server_wa

Unregisters all Web Adaptors registered with ArcGIS Server.

### arcgis-enterprise::enterprise_validate

Checks if ArcGIS Enterprise setups and authorization files exist.

### arcgis-enterprise::webstyles

Installs Portal for ArcGIS Web Styles.

Usage
-----

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2021 Esri

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
