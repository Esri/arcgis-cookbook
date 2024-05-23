---
layout: default
title: "arcgis-enterprise cookbook"
category: cookbooks
item: arcgis-enterprise
version: 5.0.0
latest: true
---

# arcgis-enterprise cookbook

This cookbook installs and configures ArcGIS Enterprise components.

## Supported ArcGIS versions

* 10.9.1
* 11.0
* 11.1
* 11.2
* 11.3

## Supported ArcGIS Software

* ArcGIS Server
* ArcGIS Data Store
* Portal for ArcGIS
* Portal for ArcGIS Web Styles
* ArcGIS Web Adaptor (IIS/Java)

## Supported Platforms

* Windows 8 (8.1). 8.1 requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows 10. Requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu Server 20.04 LTS
* Ubuntu Server 22.04 LTS
* Red Hat Enterprise Linux Server 8
* Red Hat Enterprise Linux Server 9
* SUSE Linux Enterprise Server 15
* Oracle Linux 8
* Oracle Linux 9
* Rocky Linux 8
* Rocky Linux 9
* AlmaLinux 9

> Check the system requirements of the specific ArcGIS software version to make sure that the platform is supported in that version.

## Dependencies

The following cookbooks are required:

* arcgis-repository
* hostsfile
* limits
* authbind
* iptables
* windows
* windows_firewall
* ms_dotnet

## Attributes

### General

* `node['arcgis']['version']` = ArcGIS version. Default value is `11.3`.
* `node['arcgis']['run_as_user']` = User account used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default account name is `arcgis`.
* `node['arcgis']['run_as_uid']` = Numeric identifier of user account used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default user identifier is `1100`.
* `node['arcgis']['run_as_gid']` = Numeric identifier of user group used to run ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store. Default group identifier is `1100`.
* `node['arcgis']['run_as_password']` = Password for the user account used to run ArcGIS Server,
Portal for ArcGIS, and ArcGIS Data Store. Default value is `nil`.
* `node['arcgis']['run_as_msa']` = If set to `true`, configures ArcGIS Enterprise applications to use a Windows group managed service account (gMSA). Default setting is `false`.
* `node['arcgis']['run_as_user_auth_keys']` = Path to a file with authorized SSH keys. Default value is `nil`.
* `node['arcgis']['hosts']` = Hostname to IP address mappings to be added to the /etc/hosts file. Default value is `{}`.
* `node['arcgis']['cache_authorization_files']` = If set to true, the software authorization file is cached on the machine and software authorization is skipped in the subsequent Chef runs. Default value is `false`.
* `node['arcgis']['configure_windows_firewall']` = If set to true, Windows firewall is configured for ArcGIS applications as specified by the system requirements. Default value is `false`.
* `node['arcgis']['python']['install_dir']` = Python installation directory. By default, Python is installed at `C:\Python27`.
* `node['arcgis']['post_install_script']` = Custom post-installation script path. The default path on Windows is `C:\imageryscripts\deploy.bat`; on Linux, it is `/arcgis/imageryscripts/deploy.sh`.
* `node['arcgis']['configure_cloud_settings']` = If set to `true`, makes the cookbook use the cloud provider specific ArcGIS Enterprise configuration. The default value is `true` if `node['cloud']` is defined or the arcgis_cloud_platform environment varible is set to `aws`.
* `node['arcgis']['cloud']['provider']` = Cloud provider. Default value is set to `ec2` if the arcgis_cloud_platform environment variable is set to `aws`; otherwise, it is set to the `node['cloud']['provider']` attribute value.
* `node['arcgis']['configure_autofs']` = If set to `true`, autofs package is installed and configured to enable auto-mounting of file systems on the network which are exported by NFS. The default value is `true`.
* `node['arcgis']['clean_install_dirs']` = If set to `true`, ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store installation directories are deleted by 'clean' recipe. The default value is `false`.

### File Server

* `node['arcgis']['fileserver']['directories']` = List of local directories created by 'fileserver' recipe. Default list is `[node['arcgis']['server']['local_directories_root'], node['arcgis']['data_store']['local_backup_dir'], node['arcgis']['data_store']['local_backup_dir']/tilecache, node['arcgis']['data_store']['local_backup_dir']/relational, node['arcgis']['portal']['local_content_dir']]`.
* `node['arcgis']['fileserver']['shares']` = List of local directories shared by 'fileserver' recipe. Default list is `[node['arcgis']['server']['local_directories_root'], node['arcgis']['data_store']['local_backup_dir'], node['arcgis']['portal']['local_content_dir']]`.

### Server

* `node['arcgis']['server']['wa_name']` = The name of the Web Adaptor used for ArcGIS Server. Default name is `server`.
* `node['arcgis']['server']['wa_url']` = URL of the Web Adaptor used for ArcGIS Server. Default name is `https://<FQDN of the machine>/<Server Web Adaptor name>`.
* `node['arcgis']['server']['domain_name']` = ArcGIS Server domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['server']['hostname']` = Host name or IP address of ArcGIS Server machine. Default value is  `''`.
* `node['arcgis']['server']['url']` = ArcGIS Server URL. The default URL is `https://<FQDN of the machine>:6443/arcgis` using the fully qualified domain name of the machine on which Chef is running. If ArcGIS Server and the web adaptor are running on different machines, then this value should be explicitly set.
* `node['arcgis']['server']['private_url']` = ArcGIS Server URL without Web Adaptor. Default URL is `https://<server domain name>:6443/arcgis`.
* `node['arcgis']['server']['primary_server_url']` = URL of ArcGIS Server site to join. Default is `nil`.
* `node['arcgis']['server']['web_context_url']` = ArcGIS Server web context URL that will be used for the federated server services URL. By default, this is `'https://<Domain name>/<WA name>`.
* `node['arcgis']['server']['use_join_site_tool']` = If set to true, the join-site command line tool is used to add machine to the site and the default cluster. Default value is `false`.
* `node['arcgis']['server']['admin_username']` = Primary ArcGIS Server administrator user name. Default user name is `admin`.
* `node['arcgis']['server']['admin_password']` = Primary ArcGIS Server administrator password. Default value is `nil`.
* `node['arcgis']['server']['publisher_username']` = ArcGIS Server publisher user name. Default user name is `node['arcgis']['server']['admin_username']`.
* `node['arcgis']['server']['publisher_password']` = ArcGIS Server publisher password. Default value is `node['arcgis']['server']['admin_password']`.
* `node['arcgis']['server']['directories_root']` = ArcGIS Server root directory. Default Windows directory is `C:\arcgisserver`; default Linux directory is `/arcgis/server/usr`.
* `node['arcgis']['server']['setup']` = The location of the ArcGIS Server setup executable. Default location on Windows is `<ArcGIS software setups folder>\ArcGIS <version>\ArcGISServer\Setup.exe`, on Linux is `<ArcGIS software setups folder>/ArcGIS <version>/ArcGISServer/Setup`.
* `node['arcgis']['server']['setup_options']` = Additional ArcGIS Server setup command line options. Default options are `''`.
* `node['arcgis']['server']['lp-setup']` = The location of the language pack for ArcGIS Server. Default location is `nil`.
* `node['arcgis']['server']['setup_archive']` = Path to ArcGIS Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['server']['install_dir']` = ArcGIS Server installation directory. By default, ArcGIS Server is installed to  `%ProgramW6432%\ArcGIS\Server` on Windows machines and `/` on Linux machines.
* `node['arcgis']['server']['is_hosting']` = Must be set to true for hosting server. Default value is `true`.
* `node['arcgis']['server']['install_system_requirements']` = If set to true, the required third-party libraries are installed on the machine before running the ArcGIS Server setup. Default value is `true`.
* `node['arcgis']['server']['configure_autostart']` = If set to true, on Linux ArcGIS Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['server']['authorization_file']` = ArcGIS Server authorization file path. Default location and authorization file is `''`.
* `node['arcgis']['server']['authorization_file_version']` = ArcGIS Server authorization file version. Default version is `node['arcgis']['version']`.
* `node['arcgis']['server']['authorization_options']` = Additional ArcGIS Server software authorization command line options. Default options are `''`.
* `node['arcgis']['server']['data_items']` = Array of data items that need to be registered with ArcGIS Server. Default value is `[]`.
* `node['arcgis']['server']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['keystore_password']` = Keystore file password for ArcGIS Server. Default value is `nil`.
* `node['arcgis']['server']['cert_alias']` = SSL certificate alias for ArcGIS Server. Default alias is composed of these values: `node['arcgis']['server']['domain_name']`.
* `node['arcgis']['server']['root_cert']` = ArcGIS Server root CA certificate file path. Default value is `''`.
* `node['arcgis']['server']['root_cert_alias']` = ArcGIS Server root CA certificate alias. Default value is `''`.
* `node['arcgis']['server']['system_properties']` = ArcGIS Server system properties. Default value is `{}`.
* `node['arcgis']['server']['log_level']` = ArcGIS Server log level. Default value is `WARNING`.
* `node['arcgis']['server']['log_dir']` = ArcGIS Server log directory. Default value is `C:\arcgisserver\logs` on Windows and `/arcgis/server/usr/logs` on Linux.
* `node['arcgis']['server']['max_log_file_age']` = ArcGIS Server maximum log file age. Default value is `90`.
* `node['arcgis']['server']['config_store_type']` = ArcGIS Server configuration store type. Default value is `FILESYSTEM`.
* `node['arcgis']['server']['config_store_connection_string']` = ArcGIS Server connection string. Default value is `C:\arcgisserver\config-store` on Windows and `/arcgis/server/usr/config-store` on Linux.
* `node['arcgis']['server']['config_store_connection_secret']` = ArcGIS Server configuration store type secret. Default value is `nil`.
* `node['arcgis']['server']['services']` = An array of ArcGIS Server services to be published. Default value is `{}`.
* `node['arcgis']['server']['security']['user_store_config']` = User store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['server']['security']['role_store_config']` = Role store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['server']['security']['privileges']` = Privileges to user roles assignments `{'PUBLISH' => [], 'ADMINISTER' => []}`
* `node['arcgis']['server']['soc_max_heap_size']` = SOC maximum heap size in megabytes. Default value is `64`.
* `node['arcgis']['server']['protocol']` = Protocol used by server. Default value is `HTTPS`.
* `node['arcgis']['server']['authentication_mode']` = Server authentication mode (ARCGIS_TOKEN | ARCGIS_PORTAL_TOKEN | WEB_ADAPTOR_AUTHENTICATION). If not set, the authentication mode is not changed. Default value is `''`.
* `node['arcgis']['server']['authentication_tier']` = Server authentication tier (WEB_ADAPTOR | GIS_SERVER | ARCGIS_PORTAL). If not set, the authentication tier is not changed. Default value is `''`.
* `node['arcgis']['server']['hsts_enabled']` = HTTP Strict Transport Security enabled. Default value is `false`.
* `node['arcgis']['server']['virtual_dirs_security_enabled']` = Security for virtual directories enabled. Default value is `false`.
* `node['arcgis']['server']['allow_direct_access']` = Allow direct access to server. Default value is `true`.
* `node['arcgis']['server']['allowed_admin_access_ips']` = A comma separated list of client machine IP addresses that are allowed access to ArcGIS Server. `''`.
* `node['arcgis']['server']['https_protocols']` = The TLS protocols ArcGIS Server will use. If not set, the ArcGIS Server default protocols are used. Default value is `''`
* `node['arcgis']['server']['cipher_suites']` = The cipher suites ArcGIS Server will use. If not set, the ArcGIS Server default cipher suites are used. Default value is `''`
* `node['arcgis']['server']['ports']` = Ports opened in Windows firewall for ArcGIS Server. Default ports are `1098,6006,6080,6099,6443`.
* `node['arcgis']['server']['geoanalytics_ports]` = Ports opened in Windows firewall for ArcGIS GeoAnalytics Server. Default ports are `7077,12181,12182,12190,56540-56545`.
* `node['arcgis']['server']['pull_license]` = If set to `true`, the server_node recipe pulls the ArcGIS Server license from other server machines in the site. The default value is `false`.
* `node['arcgis']['server']['patches]` = File names of ArcGIS Server patches to install. Default value is `[]`.
* `node['arcgis']['server']['services_dir_enabled']` = If set to `true` enables ArcGIS Server services directory. Default value is `true`.
* `node['arcgis']['server']['unpack_options']` = ArcGIS Server windows self-extracting archive command line options. Default value is `/x` for ArcGIS Server 11.3 and `''` for older versions.

### Web Adaptor

* `node['arcgis']['web_adaptor']['admin_access']` = Indicates if ArcGIS Server Manager and Admin API will be available through the Web Adaptor `<true|false>`. Default value is `false`.
* `node['arcgis']['web_adaptor']['setup']` = Location of ArcGIS Web Adaptor setup executable. Default location is `C:\<ArcGIS software setups folder>\ArcGIS <version>\WebAdaptorIIS\Setup.exe` on Windows and `<ArcGIS software setups folder>/<version>/WebAdaptor/Setup` on Linux.
* `node['arcgis']['web_adaptor']['setup_options']` = Additional Web Adaptor setup command line options. Default options are `''`.
* `node['arcgis']['web_adaptor']['lp-setup']` = The location of the language pack for ArcGIS Web Adaptor. Default location is `nil`.
* `node['arcgis']['web_adaptor']['setup_archive']` = Path to ArcGIS Web Adaptor setup archive. Default value depends on `node['arcgis']['version']` attribute value. 
* `node['arcgis']['web_adaptor']['install_dir']` = ArcGIS Web Adaptor installation directory (Linux only). By default, ArcGIS Web Adaptor is installed to `/` on Linux.
* `node['arcgis']['web_adaptor']['reindex_portal_content']` = If set to `true`, Web Adaptor registration reindexes Portal for ArcGIS content. Default value is `true`.
* `node['arcgis']['web_adaptor']['patches]` = File names of ArcGIS Web Adaptor patches to install. Default value is `[]`.
* `node['arcgis']['web_adaptor']['install_system_requirements']` = If set to true, the required third-party packages are installed on the machine before running the ArcGIS Web Adaptor setup. Default value is `true`.
* `node['arcgis']['web_adaptor']['dotnet_setup_path']` = Path to ASP.NET Core Runtime Hosting Bundle setup. Default path is `<ArcGIS software setups folder>\dotnet-hosting-8.0.0-win.exe`.
* `node['arcgis']['web_adaptor']['web_deploy_setup_path']` = Path to Web Deploy setup. Default path is `<ArcGIS software setups folder>\WebDeploy_amd64_en-US.msi`.

### Portal

* `node['arcgis']['portal']['domain_name']` = Portal for ArcGIS domain name. By default, `<node FQDN>` is used.
* `node['arcgis']['portal']['wa_name']` = The Web Adaptor name for Portal for ArcGIS. Default name is `portal`.
* `node['arcgis']['portal']['wa_url']` = URL of the Web Adaptor for Portal for ArcGIS. Default name is `https://<FQDN of the machine>/<Portal Web Adaptor name>`.
* `node['arcgis']['portal']['url']` = Portal for ArcGIS URL. The default URL is `https://<FQDN of the machine>:7443/arcgis` using the fully qualified domain name of the machine on which Chef is running. If Portal for ArcGIS and the web adaptor are running on different machines, then this value should be explicitly set.
* `node['arcgis']['portal']['private_url']` = Portal for ArcGIS private URL. Default URL is `https://<portal domain name>:7443/arcgis`.
* `node['arcgis']['portal']['primary_machine_url']` = URL of primary Portal for ArcGIS machine. By default, this is `nil`.
* `node['arcgis']['portal']['admin_username']` = Initial portal administrator user name. Default user name is `admin`.
* `node['arcgis']['portal']['admin_password']` = Initial portal administrator password. Default password is `nil`.
* `node['arcgis']['portal']['admin_email']` = Initial portal administrator e-mail. Default email is `admin@mydomain.com`.
* `node['arcgis']['portal']['admin_full_name']` = Initial portal administrator full name. Default full name is `Administrator`.
* `node['arcgis']['portal']['admin_description']` = Initial portal administrator description. Default description is `Initial portal account administrator`.
* `node['arcgis']['portal']['security_question']` = Security question. Default question is `Your favorite ice cream flavor?`
* `node['arcgis']['portal']['security_question_answer']` = Security question answer. Default answer is `avocado`.
* `node['arcgis']['portal']['setup']` = Portal for ArcGIS setup path. Default location is `<ArcGIS software setups folder>\ArcGIS <version\PortalForArcGIS\Setup.exe` on Windows and `<ArcGIS software setups folder>/<version>/PortalForArcGIS/Setup` on Linux.
* `node['arcgis']['portal']['setup_options']` = Additional Portal for ArcGIS setup command line options. Default options are `''`.
* `node['arcgis']['portal']['lp-setup']` = The location of the language pack for Portal for ArcGIS. Default location is `nil`.
* `node['arcgis']['portal']['setup_archive']` = Path to Portal for ArcGIS setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['portal']['install_dir']` = Portal for ArcGIS installation directory. By default, Portal for ArcGIS is installed to `%ProgramW6432%\ArcGIS\Portal` on Windows machines and `/` on Linux machines.
* `node['arcgis']['portal']['install_system_requirements']` = If set to true, the required third-party libraries are installed on the machine before running the Portal for ArcGIS setup. Default value is `true`.
* `node['arcgis']['portal']['configure_autostart']` = If set to true, on Linux Portal for ArcGIS is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['portal']['data_dir']` = Data directory path used by the Portal for ArcGIS setup. The path must be a local directory, not a shared network directory. Default path on Windows is `C:\arcgisportal`; on Linux, it is `/arcgis/portal/usr/arcgisportal/`.
* `node['arcgis']['portal']['content_dir']` = Portal for ArcGIS content directory. Default directory is `C:\arcgisportal\content` on Windows and `/arcgis/portal/usr/arcgisportal/content` on Linux.
* `node['arcgis']['portal']['authorization_file']` = Portal for ArcGIS authorization file path. Default location and file name is `''`.
* `node['arcgis']['portal']['authorization_file_version']` = Portal for ArcGIS authorization file version. Default value is `11.3`.
* `node['arcgis']['portal']['user_license_type_id']` = Portal for ArcGIS administrator user license type Id.
* `node['arcgis']['portal']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with SSL certificate for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['keystore_password']` = Keystore file password for Portal for ArcGIS. Default value is `nil`.
* `node['arcgis']['portal']['cert_alias']` = SSL certificate alias for Portal for ArcGIS. Default alias is composed of these values:`node['arcgis']['portal']['domain_name']`.
* `node['arcgis']['portal']['hostname']` = Host name or IP address of Portal for ArcGIS machine specified in the hostname.properties file. Default value is  `''`.
* `node['arcgis']['portal']['hostidentifier']` = Host name or IP address of Portal for ArcGIS machine specified in hostidentifier.properties file. Default value is `node['arcgis']['portal']['hostname']`.
* `node['arcgis']['portal']['preferredidentifier']` = Portal for ArcGIS preferred identifier method `<hostname|ip>`. Default method used is `hostname`.
* `node['arcgis']['portal']['content_store_type']` = Portal for ArcGIS content store type `<FileStore|CloudStore>`. Default value is `FileStore`.
* `node['arcgis']['portal']['content_store_provider']` = Portal for ArcGIS content store provider `<Amazon|FileSystem>`. Default value is `FileSystem`.
* `node['arcgis']['portal']['content_store_connection_string']` = Portal for ArcGIS content store connection string. Default connection string is `node['arcgis']['portal']['content_dir']`.
* `node['arcgis']['portal']['object_store']` = Portal for ArcGIS content store container such as an S3 bucket name. Default value is `nil`.
* `node['arcgis']['portal']['log_level']` = Portal for ArcGIS log level. Default value is `WARNING`.
* `node['arcgis']['portal']['log_dir']` = Portal for ArcGIS log directory. Default value is `C:\arcgisportal\logs` on Windows and `/arcgis/portal/usr/arcgisportal/logs` on Linux.
* `node['arcgis']['portal']['max_log_file_age']` = Portal for ArcGIS maximum log file age. Default value is `90`.
* `node['arcgis']['portal']['upgrade_backup']` = Back up Portal for ArcGIS content during upgrade. Default value is `true`.
* `node['arcgis']['portal']['upgrade_rollback']` = Roll back Portal for ArcGIS upgrade in case of failure. Default value is `true`.
* `node['arcgis']['portal']['root_cert']` = Portal for ArcGIS root certificate. Default value is `''`.
* `node['arcgis']['portal']['root_cert_alias']` = Portal for ArcGIS root certificate alias. Default value is `''`.
* `node['arcgis']['portal']['allssl']` = Portal for ArcGIS run in all SSL mode or not. Default value is `false`.
* `node['arcgis']['portal']['security']['user_store_config']` = User store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['portal']['security']['role_store_config']` = Role store configuration. Default value is `{'type' => 'BUILTIN', 'properties' => {}}`
* `node['arcgis']['portal']['system_properties']` = Portal for ArcGIS system properties. Default value is `{}`.
* `node['arcgis']['portal']['ports']` = Ports opened in Windows firewall for Portal for ArcGIS. Default ports are `5701,5702,5703,7080,7443,7005,7099,7120,7220,7654,7820,7830,7840`.
* `node['arcgis']['portal']['patches]` = File names of Portal for ArcGIS patches to install. Default value is `[]`.
* `node['arcgis']['portal']['webgisdr_properties']` = webgisdr tool properties. Default value is `{}`.
* `node['arcgis']['portal']['webgisdr_timeout']` = webgisdr tool execution timeout in seconds. Default timeout is `36000`.
* `node['arcgis']['portal']['unpack_options']` = Portal for ArcGIS windows self-extracting archive command line options. Default value is `/x` for Portal for ArcGIS 11.3 and `''` for older versions.
* `node['arcgis']['portal']['enable_debug']` = Specifies the log level when creating and upgrading Portal for ArcGIS site. If `true`, the log level is set to DEBUG, otherwise the log level is set to VERBOSE. The default value is `false`.

### Web Styles

* `node['arcgis']['webstyles']['setup']` = ArcGIS Web Styles setup path.
* `node['arcgis']['webstyles']['setup_options']` = Additional ArcGIS Web Styles setup command line options. Default options are `''`.
* `node['arcgis']['webstyles']['setup_archive']` = ArcGIS Web Styles setup archive path. Default value depends on `node['arcgis']['version']` attribute value.

### Data Store

* `node['arcgis']['data_store']['data_dir']` = ArcGIS Data Store data directory. Default location is `C:\arcgisdatastore` on Windows and `/arcgis/datastore/usr/arcgisdatastore` on Linux.
* `node['arcgis']['data_store']['backup_dir']` = ArcGIS Data Store backup directory. Default location is `C:\arcgisbackup` on Windows and `/arcgis/datastore/usr/arcgisbackup` on Linux.
* `node['arcgis']['data_store']['setup']` = Location of ArcGIS Data Store setup executable. Default location is `<ArcGIS software setups folder>\ArcGIS <version>\ArcGISDataStore\Setup.exe` on Windows and `<ArcGIS software setups folder>/<version>/ArcGISDataStore_Linux/Setup` on Linux.
* `node['arcgis']['data_store']['setup_options']` = Additional ArcGIS Data Store setup command line options. Default options are `''`.
* `node['arcgis']['data_store']['lp-setup']` = The location of the language pack for ArcGIS Data Store. Default location is `nil`.
* `node['arcgis']['data_store']['setup_archive']` = Path to ArcGIS Data Store setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['data_store']['install_dir']` = ArcGIS Data Store installation directory. By default, ArcGIS Data Store is installed to `%ProgramW6432%\ArcGIS\DataStore` on Windows and `/` on Linux.
* `node['arcgis']['data_store']['install_system_requirements']` = If set to true, the required third-party libraries are installed on the machine before running the ArcGIS Data Store setup. Default value is `true`.
* `node['arcgis']['data_store']['configure_autostart']` = If set to true, on Linux ArcGIS Data Store is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['data_store']['hostidentifier']` = Host name or IP address of ArcGIS Data Store machine. Default value is  `''`.
* `node['arcgis']['data_store']['preferredidentifier']` = ArcGIS Data Store preferred identifier method `<hostname|ip>`. Default method used is `hostname`.
* `node['arcgis']['data_store']['types']` = Comma-separated list of ArcGIS Data Store types to be created, `<relational|tileCache|spatiotemporal|graph|object>`. The default value is `tileCache,relational`.
* `node['arcgis']['data_store']['mode']` = Tile cache ArcGIS Data Store mode, `<primaryStandby|cluster>`. Supported from ArcGIS Data Store 10.8.1. The default value is empty string ``, which means the default mode for the ArcGIS Data Store version is used or the currently configured mode is used.
* `node['arcgis']['data_store']['roles']` = Comma-separated list of Spatiotemporal ArcGIS Data Store roles, `[coord][,][data]`. Supported from ArcGIS Data Store 11.3. The default value is `''`.
* `node['arcgis']['data_store']['relational']['backup_type']` = Type of location to use for relational data store backups `<fs|s3|azure|none>`. The default value is `fs` for file system.
* `node['arcgis']['data_store']['relational']['backup_location']` = Relational data store backup location. The default location is `node['arcgis']['data_store']['backup_dir']/relational`.
* `node['arcgis']['data_store']['tilecache']['backup_type']` = Type of location to use for tile cache data store backups `<fs|s3|azure|none>`. The default value is `fs` for file system.
* `node['arcgis']['data_store']['tilecache']['backup_location']` = Tile cache data store backup location. The default location is `node['arcgis']['data_store']['backup_dir']/tilecache`.
* `node['arcgis']['data_store']['object']['backup_type']` = Type of location to use for object data store backups `<fs|s3|azure|none>`. The default value is `fs` for file system.
* `node['arcgis']['data_store']['object']['backup_location']` = Object data store backup location. The default location is `node['arcgis']['data_store']['backup_dir']/object`.
* `node['arcgis']['data_store']['force_remove_machine']` = Specify true only if the ArcGIS Server site is unavailable when ArcGIS Data Store machine is removed. Default value is `false`.
* `node['arcgis']['data_store']['ports']` = Ports opened in Windows firewall for ArcGIS Data Store. Default ports are `2443,4369,9220,9320,9820,9829,9830,9831,9840,9876,9900,25672,44369,45671,45672,29079-29090`.
* `node['arcgis']['data_store']['patches]` = File names of ArcGIS Data Store patches to install. Default value is `[]`.  

### Linux Web Server

* `node['arcgis']['web_server']['webapp_dir']` = Path to web server's web application directory (e.g., /opt/tomcat/webapps). Default value is `''`

## Recipes

### clean

Deletes data and installation directories of ArcGIS Server, Portal for ArcGIS, and ArcGIS Data Store.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "clean_install_dirs": false,
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "directories_root": "C:\\arcgisserver"
    },
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "data_dir": "C:\\arcgisportal"
    },
    "data_store": {
      "install_dir": "C:\\Program Files\\ArcGIS\\DataStore",
      "data_dir": "C:\\arcgisdatastore"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::clean]"
  ]
}
```

### datasources

> The recipe is not supported with ArcGIS Enterprise 11.0. Instead of arcgis-enterprise::datasources recipe, use the arcgis-enterprise::fileserver recipe to create network shares and arcgis-enterprise::server_data_items to register data items with ArcGIS Server.

The recipe is used to:
- Create local folders in the Node's file system,
- Create Windows network shares,
- Register a folder as an ArcGIS Server's data source --> you can even set different publisher and server paths,
- Register either a folder with SDE connection files or an array of SDE connection files as ArcGIS Server data sources,
- Block the copying of data to ArcGIS Server when publishing content.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://sitehost.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    },
    "datasources":{
      "block_data_copy":true,
      "folders":[
        {
          "server_path":"D:\\Mapfiles",
          "create_folder":true,
          "security_permissions":{
            "authorize_arcgis_service_account":true
          },
          "share_folder":true,
          "share_name":"Mapfiles",
          "sharing_permissions":{
            "full_control_members":["MyDomain\\MyUser", "MyDomain\\MyGroup"]
          },
          "publish_folder":{
            "identifier":"Mapfiles",
            "publish_with_hostname":true
          }
        },{
          "server_path":"D:\\Data",
          "create_folder":true,
          "security_permissions":{
            "authorize_arcgis_service_account":true,
            "full_control_members":["MyDomain\\MyUser", "MyDomain\\MyGroup"]
          },
          "share_folder":true,
          "share_name":"Data",
          "sharing_permissions":{
            "full_control_members":["MyDomain\\MyUser", "MyDomain\\MyGroup"]
          },
          "publish_folder":{
            "identifier":"Data",
            "publish_with_hostname":true
          }
        },{
          "server_path":"D:\\Data",
          "publish_folder":{
            "identifier":"Data_With_Alias",
            "publish_alternative_path":"\\\\<<DNS-Alias>>\\Data"
          }
        },{
          "publish_folder":{
            "identifier":"OtherData",
            "publish_alternative_path":"\\\\Path\\To\\Other\\Data"
          }
        }
      ],
      "sde_files":{
        "folder":"\\\\Folder\\With\\SDE\\Files",
        "files":["\\\\AnotherFolder\\With\\SDE\\Files\\File1.sde", "\\\\AnotherFolder\\With\\SDE\\Files\\File2.sde"]
      }
    }
  },
  "run_list":[
    "recipe[arcgis-enterprise::datasources]"
  ]
}
```

### datastore

Installs and configures ArcGIS Data Store on the primary machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "configure_windows_firewall": false,
    "server": {
      "url": "https://SERVER:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    },
    "data_store": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\DataStore\\Setup.exe",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "install_dir": "C:\\Program Files\\ArcGIS\\DataStore",
      "data_dir": "C:\\arcgisdatastore",
      "backup_dir": "C:\\arcgisdatastore\\backup",
      "types": "tileCache,relational,spatiotemporal",
      "preferredidentifier": "hostname"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::datastore]"
  ]
}
```

The recipe uses ```https://<server domain_name>:6443/arcgis``` server URL when it configures ArcGIS Data Store.

### datastore_standby

Installs and configures ArcGIS Data Store on the standby machine.

The recipe uses the same attributes as the arcgis-enterprise::datastore recipe.

### disable_geoanalytics

Resets the GeoAnalytics configuration on the ArcGIS Enterprise portal. 

Applies to: ArcGIS 10.5 and newer versions.

The recipe uses the same attributes as the arcgis-enterprise::enable_geoanalytics recipe.

### disable_imagehosting

Resets the image hosting configuration on the ArcGIS Enterprise portal.

Applies to: ArcGIS 10.5 and newer versions.

The recipe uses the same attributes as the arcgis-enterprise::enable_imagehosting recipe.

### disable_rasteranalytics

Resets the raster analytics server role in the ArcGIS Enterprise portal.

Applies to: ArcGIS 10.5 and newer versions.

The recipe uses the same attributes as the arcgis-enterprise::enable_rasteranalytics recipe.

### egdb

Registers an enterprise geodatabase with ArcGIS Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "private_url": "https://domain.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::egdb]"
  ]
}
```

### enable_geoanalytics

Configures the Portal for ArcGIS to perform big data analytics.

Applies to: ArcGIS 10.5 and newer versions.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "server": {
      "private_url": "https://domain.com:6443/arcgis",
      "web_context_url": "https://domain.com/server",
      "admin_username": "admin",
      "admin_password": "<password>",
      "is_hosting": false
    },
    "portal": {
      "private_url": "https://portal.domain.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enable_geoanalytics]"
  ]
}
```

### enable_imagehosting

Configures the ArcGIS Enterprise portal for image hosting.

Applies to: ArcGIS 10.5 and newer versions.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "server": {
      "private_url": "https://domain.com:6443/arcgis",
      "web_context_url": "https://domain.com/server",
      "admin_username": "admin",
      "admin_password": "<password>",
      "is_hosting": false
    },
    "portal": {
      "private_url": "https://portal.domain.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enable_imagehosting]"
  ]
}
```

### enable_rasteranalytics

Configures the ArcGIS Enterprise portal to perform raster analytics.

Applies to: ArcGIS 10.5 and newer versions.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "server": {
      "private_url": "https://domain.com:6443/arcgis",
      "web_context_url": "https://domain.com/server",
      "admin_username": "admin",
      "admin_password": "<password>",
      "is_hosting": false
    },
    "portal": {
      "private_url": "https://portal.domain.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enable_rasteranalytics]"
  ]
}
```

### enterprise_installed

Installs ArcGIS Server, Portal for ArcGIS, ArcGIS Data Store, and ArcGIS Web Adaptors for server and portal.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "server": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Server\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "wa_name": "server"
    },
    "portal": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Portal\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "wa_name": "portal"
    },
    "data_store": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\DataStore\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\DataStore"
    },
    "web_adaptor": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\WebAdaptorIIS\\Setup.exe",
      "install_dir": ""
    },
    "python": {
      "install_dir": "C:\\Python27"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enterprise_installed]"
  ]
}
```

### enterprise_uninstalled

Uninstalls all ArcGIS Enterprise software of the specified version.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "wa_name": "server"
    },
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "wa_name": "portal"
    },
    "data_store": {
      "install_dir": "C:\\Program Files\\ArcGIS\\DataStore"
    },
    "web_adaptor": {
      "install_dir": ""
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enterprise_uninstalled]"
  ]
}
```

### enterprise_validate

Checks if ArcGIS Enterprise setups and authorization files exist.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Server\\Setup.exe",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Server.prvc"
    },
    "portal": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Portal\\Setup.exe",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Portal.json"
    },
    "data_store": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\DataStore\\SetupFile\\Setup.exe"
    },
    "web_adaptor": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\WebAdaptorIIS\\Setup.exe"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::enterprise_validate]"
  ]
}
```

### federation

Federates an ArcGIS Server site with the ArcGIS Enterprise portal.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "domain_name": "domain.com",
      "private_url": "https://domain.com:6443/arcgis",
      "web_context_url": "https://domain.com/server",
      "admin_username": "admin",
      "admin_password": "<password>",
      "is_hosting": true
    },
    "portal": {
      "private_url": "https://portal.domain.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "root_cert": "",
      "root_cert_alias"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::federation]"
  ]
}
```

### fileserver

Creates and shares directories on a file server machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis", 
    "run_as_password": "<password>",
    "fileserver": {
       "directories": [
          "C:\\data\\arcgisserver",
          "C:\\data\\arcgisbackup",
          "C:\\data\\arcgisbackup\\tilecache",
          "C:\\data\\arcgisbackup\\relational",
          "C:\\data\\arcgisportal",
          "C:\\data\\arcgisportal\\content"
       ],
       "shares": [
          "C:\\data\\arcgisserver",
          "C:\\data\\arcgisbackup",
          "C:\\data\\arcgisportal"
       ]
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::fileserver]"
  ]
}
```

### hosts

Creates entries in the /etc/hosts file for the specified hostname to IP address map.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "hosts": {
      "domain.com": "12.34.56.78",
      "node.com": ""
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::hosts]"
  ]
}
```

For empty IP address strings, the IPv4 address of the machine is used.

### iptables

Configures iptables to forward ports 80/443 to 8080/8443.

### install_datastore

Installs ArcGIS Data Store on the machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "data_store": {
      "setup": "C:\\Users\\Administrator\\Documents\\ArcGIS 11.3\\ArcGISDataStore\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\DataStore",
      "data_dir": "C:\\arcgisdatastore",
      "backup_dir": "C:\\arcgisdatastore\\backup",      
      "install_system_requirements": true,
      "configure_autostart": true
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_datastore]"
  ]
}
```

### install_portal

Installs Portal for ArcGIS on the machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "portal": {
      "setup": "C:\\Users\\Administrator\\Documents\\ArcGIS 11.3\\PortalForArcGIS\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "data_dir": "C:\\arcgisportal"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_portal]"
  ]
}
```

### install_portal_wa

Installs ArcGIS Web Adaptor instance for Portal for ArcGIS.

Attributes used by the recipe on Windows:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_adaptor": {
      "setup": "C:\\Users\\Administrator\\Documents\\ArcGIS 11.3\\WebAdaptorIIS\\Setup.exe",
      "install_dir": "",
      "install_system_requirements": true
    },
    "portal": {
      "wa_name": "portal"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_portal_wa]"
  ]
}
```

### install_server

Installs ArcGIS Server on the machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "server": {
      "setup": "C:\\Users\\Administrator\\Documents\\ArcGIS 11.3\\ArcGISServer\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "install_system_requirements": true,
      "configure_autostart": true
    },
    "python": {
      "install_dir": "C:\\Python27"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_server]"
  ]
}
```

### install_server_wa

Installs ArcGIS Web Adaptor instance for ArcGIS Server.

Attributes used by the recipe on Windows:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_adaptor": {
      "setup": "C:\\Users\\Administrator\\Documents\\ArcGIS 11.3\\WebAdaptorIIS\\Setup.exe",
      "install_dir": ""
    },
    "server": {
      "wa_name": "server"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_server_wa]"
  ]
}
```

### lp-install

Installs language packs for ArcGIS Enterprise software.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "server": {
      "lp-setup": "C:\\ArcGIS\\11.3\\Setups\\Server\\Japanese\\setup.msi"
    },
    "portal": {
      "lp-setup": "C:\\ArcGIS\\11.3\\Setups\\Portal\\Japanese\\setup.msi"
    },
    "data_store": {
      "lp-setup": "C:\\ArcGIS\\11.3\\Setups\\DataStore\\Japanese\\setup.msi"
    },
    "web_adaptor": {
      "lp-setup": "C:\\ArcGIS\\11.3\\Setups\\WebAdaptorIIS\\Japanese\\setup.msi"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::lp-install]"
  ]
}
```

### install_patches

Installs hot fixes and patches for ArcGIS Enterprise software.

The recipe installs patches specified by the arcgis.portal.patches, arcgis.server.patches, arcgis.datastore.patches, and arcgis.webadaptor.patches attributes. The patch names may contain a wildcard '\*'. For example, "ArcGIS-1091-\*.msp" specifies all .msp patches that start with "ArcGIS-1091-".

Before installing patches, the recipe runs Portal for ArcGIS Validation and Repair tool on 11.1 and 10.9.1 windows machines with Portal for ArcGIS installed.

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "portal": {
      "patches": ["patch1.msp", "patch2.msp"]
    },
    "server": {
      "patches": ["patch3.msp", "patch4.msp"]
    },
    "datastore": {
      "patches": ["patch5.msp", "patch6.msp"]
    },
    "webadaptor": {
      "patches": ["patch7.msp", "patch8.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::install_patches]"
  ]
}
```

### portal

Installs, authorizes, and configures Portal for ArcGIS.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "cache_authorization_files": false,
    "configure_windows_firewall": false,
    "portal": {
      "domain_name": "portal.domain.com",
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Portal\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\portal.json",
      "user_license_type_id" : "creatorUT",
      "authorization_file_version": "11.3",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "data_dir": "C:\\arcgisportal",
      "content_dir":"C:\\arcgisportal\\content",   
      "log_dir":"C:\\arcgisportal\\logs",   
      "log_level": "WARNING",
      "max_log_file_age": 90,
      "content_store_type": "fileStore",
      "content_store_provider": "FileSystem",
      "content_store_connection_string": "C:\\arcgisportal\\content",
      "object_store": null,
      "url": "https://localhost:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "admin_email":"admin@domain.com",
      "admin_full_name": "Administrator",
      "admin_description": "Initial account administrator",
      "security_question":"Your favorite ice cream flavor?",
      "security_question_answer":"bacon",
      "keystore_file": "C:\\domain_com.pfx",
      "keystore_password": "test",
      "cert_alias": "portal.domain.com",
      "root_cert": "",
      "root_cert_alias": "",
      "upgrade_backup": true,
      "upgrade_rollback": true,
      "system_properties": {
       
      }
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::portal]"
  ]
}
```

### portal_security

Configures Portal for ArcGIS identity stores and assigns privileges to roles.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "portal": {
      "url": "https://sitehost.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "security": {
        "user_store_config" : {
          "type" : "BUILTIN", 
          "properties" : {
          }
        },
        "role_store_config" : {
          "type" : "BUILTIN", 
          "properties" : {
          }
        }
      }
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::portal_security]"
  ]
}
```

### portal_standby

Installs and configures Portal for ArcGIS on the standby machine

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "cache_authorization_files": false,
    "configure_windows_firewall": false,
    "portal": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Portal\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Portal.prvc",
      "authorization_file_version": "11.3",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "data_dir": "C:\\arcgisportal",
      "content_dir":"C:\\arcgisportal\\content",   
      "url": "https://standby.com:7443/arcgis",
      "primary_machine_url": "https://primary.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "upgrade_backup": true,
      "upgrade_rollback": true
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::portal_standby]"
  ]
}
```

### portal_wa

Installs ArcGIS Web Adaptor and configures it with Portal for ArcGIS. IIS or Java application server, such as Tomcat, must be installed and configured before installing ArcGIS Web Adaptor.

Attributes used by the recipe on Windows:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_adaptor": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\WebAdaptorIIS\\Setup.exe",
      "install_dir": "",
      "install_system_requirements": true
    },
    "portal": {
      "wa_name": "portal",
      "wa_url": "https://primary.com/portal",
      "url": "https://primary.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::portal_wa]"
  ]
}
```

Attributes used by the recipe on Linux:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_server": {
      "webapp_dir": "/opt/tomcat_arcgis/webapps"
    },
    "web_adaptor":{
      "setup": "/arcgis/11.3/WebAdaptor/CD_Linux/Setup",
      "install_dir": "/",
      "install_system_requirements": true
    },
    "portal": {
      "wa_name": "portal",
      "wa_url": "https://primary.com/portal",
      "url": "https://primary.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::portal_wa]"
  ]
}
```

### post_install

Executes custom post-installation script if it exists.

```JSON
{
  "arcgis": {
    "post_install_script": "C:\\imageryscripts\\deploy.bat"
  }
}
```

### server

Installs and configures ArcGIS Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "cache_authorization_files": false,
    "configure_windows_firewall": false,
    "server": {
      "setup": "C:\\ArcGIS\\10.5\\Setups\\Server\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Server.prvc",
      "authorization_file_version": "11.3",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "directories_root": "C:\\arcgisserver",
      "url": "https://sitehost.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "system_properties": {},
      "services_dir_enabled": true,
      "log_level": "WARNING",
      "log_dir": "C:\\arcgisserver\\logs",
      "max_log_file_age": 90,
      "config_store_type": "FILESYSTEM",
      "config_store_connection_string": "C:\\arcgisserver\\config-store",
      "config_store_connection_secret": "",
      "keystore_file": "C:\\domain_com.pfx",
      "keystore_password": "test",
      "cert_alias": "domain.com",
      "soc_max_heap_size" : 64
    },
    "python": {
      "install_dir": "C:\\Python27"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::server]"
  ]
}
```

### server_data_items

Registers data items with ArcGIS Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "server": {
            "url": "https://sitehost.com:6443/arcgis",
            "admin_username": "siteadmin",
            "admin_password": "change.it",
            "data_items": [
                {
                    "path": "/rasterStores/RasterStore",
                    "type": "rasterStore",
                    "info": {
                        "connectionString": "{\"path\":\"\\\\\\\\FILESERVER\\\\arcgisserver\\\\rasterstore\"}",
                        "connectionType": "fileShare"
                    }
                }
            ]
        }
    },
    "run_list": [
        "recipe[arcgis-enterprise::server_data_items]"
    ]
}
```

### server_node

Installs ArcGIS Server on the machine and joins an existing site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "cache_authorization_files": false,
    "configure_windows_firewall": false,
    "server": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\Server\\Setup.exe",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Server.prvc",
      "authorization_file_version": "11.3",
      "install_system_requirements":  true,
      "configure_autostart": true,
      "directories_root": "C:\\arcgisserver",
      "log_dir": "C:\\arcgisserver\\logs",
      "url": "https://node.com:6443/arcgis",
      "primary_server_url": "https://sitehost.com:6443/arcgis",
      "use_join_site_tool": false,
      "admin_username": "admin",
      "admin_password": "<password>",
      "keystore_file": "C:\\domain_com.pfx",
      "keystore_password": "test",
      "cert_alias": "domain.com",
      "soc_max_heap_size" : 64
    },
    "python": {
      "install_dir": "C:\\Python27"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::server_node]"
  ]
}
```

### server_security

Configures ArcGIS Server identity stores and assigns privileges to roles.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://sitehost.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "security": {
        "user_store_config" : {
          "type" : "BUILTIN", 
          "properties" : {
          }
        },
        "role_store_config" : {
          "type" : "BUILTIN", 
          "properties" : {
        },
        "privileges" : {
          "PUBLISH" : [], 
          "ADMINISTER" : []
        }
      }
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::server_security]"
  ]
}
```

### server_wa

Installs ArcGIS Web Adaptor and configures it with ArcGIS Server. IIS or Java application server, such as Tomcat, must be installed and configured before installing ArcGIS Web Adaptor.

Attributes used by the recipe on Windows:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_adaptor": {
      "setup": "C:\\ArcGIS\\11.3\\Setups\\WebAdaptorIIS\\Setup.exe",
      "install_dir": "",
      "install_system_requirements": true,
      "admin_access": true
    },
    "server": {
      "wa_name": "server",
      "wa_url": "https://node.com/server",
      "url": "https://node.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::server_wa]"
  ]
}
```

Attributes used by the recipe on Linux:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "web_server": {
      "webapp_dir": "/opt/tomcat_arcgis/webapps"
    },
    "web_adaptor":{
      "setup": "/arcgis/11.3/WebAdaptor/CD_Linux/Setup",
      "install_dir": "/",
      "install_system_requirements": true,
      "admin_access": true
    },
    "portal": {
      "wa_name": "server",
      "wa_url": "https://node.com/server",
      "url": "https://node.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::server_wa]"
  ]
}
```

### services

Publishes services to ArcGIS Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://domain.com:6443/arcgis",
      "publisher_username": "publisher",
      "publisher_password": "<password>",
      "services": [{
         "folder": "",
         "name": "MyMap",
         "type": "MapServer",
         "definition_file": "C:\\data\\map_bv.sd",
         "properties": {
           "maxInstancesPerNode" : 4
         } 
      }] 
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::services]"
  ]
}
```

Service configuration properties, such as configuredState, minInstancesPerNode, maxInstancesPerNode, and all other properties can be specified by the node['arcgis']['server']['services']['properties'] attribute. 

### sql_alias

Creates SQL Server alias 'egdbhost' for Amazon RDS endpoint.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server"
    },
    "rds": {
      "engine": "sqlserver-se",
      "endpoint": "myinstance.123456789012.us-east-1.rds.amazonaws.com:1433"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::sql_alias]"
  ]
}
```

### start_datastore

Starts ArcGIS Data Store on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::start_datastore]"
  ]
}
```

### start_portal

Starts Portal for ArcGIS on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::start_portal]"
  ]
}
```

### start_server

Starts ArcGIS Server on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::start_server]"
  ]
}
```

### stop_datastore

Stops ArcGIS Data Store on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::stop_datastore]"
  ]
}
```

### stop_machine

Stops the local machine in an ArcGIS Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://domain.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::stop_machine]"
  ]
}
```

### stop_portal

Stops Portal for ArcGIS on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::stop_portal]"
  ]
}
```

### stop_server

Stops ArcGIS Server on the machine.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-enterprise::stop_server]"
  ]
}
```

### system

Creates arcgis user account, includes 'hosts' recipe. On Linux, the recipe also sets process and file limits for the user account to 25059 and 65535 respectively to meet the requirements of ArcGIS Enterprise setups.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "hosts": {
      "domain.com": "12.34.56.78",
      "local.com": ""
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::system]"
  ]
}
```

`node['arcgis']['run_as_password']` attribute is not required on Linux.

### unfederate_server

Unfederates an ArcGIS Server from the ArcGIS Enterprise portal.

> Caution: Unfederating an ArcGIS Server site has several significant consequences and should not be done as part of routine troubleshooting. It is an act that is not easily undone and may have irreversible consequences. Only unfederate a site if you have a clear understanding of the impact. See [Administer a federated server](https://enterprise.arcgis.com/en/portal/latest/administer/windows/administer-a-federated-server.htm) for more details.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "web_context_url": "https://domain.com/server"
    },
    "portal": {
      "private_url": "https://portal.domain.com:7443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::unfederate_server]"
  ]
}
```

### unregister_machine

Unregisters the local machine from the ArcGIS Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://domain.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::unregister_machine]"
  ]
}
```

### unregister_machines

Unregisters from the ArcGIS Server site all the server machines except for the local machine.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://domain.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "<password>",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::unregister_machines]"
  ]
}
```

### unregister_server_wa

Unregisters all ArcGIS Web Adaptors from the ArcGIS Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "use_join_site_tool": false,
      "url": "https://SERVER:6443/arcgis",
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "admin_username": "siteadmin",
      "admin_password": "change.it"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::unregister_server_wa]"
  ]
}
```

### unregister_stopped_machines

Unregisters stopped machines that are in an ArcGIS Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "server": {
      "url": "https://SERVER:6443/arcgis",
      "admin_username": "siteadmin",
      "admin_password": "change.it"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::unregister_stopped_machines]"
  ]
}
```

### webgisdr_export

Creates ArcGIS Enterprise backup using WebGISDR utility.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "run_as_user": "acrgis",
    "run_as_password": "<run_as_password>",
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "webgisdr_timeout": 36000,      
      "webgisdr_properties": {
        "PORTAL_ADMIN_URL": "https://domain.com:7443/arcgis",
        "PORTAL_ADMIN_USERNAME": "sitedmin",
        "PORTAL_ADMIN_PASSWORD": "<password>",
        "PORTAL_ADMIN_PASSWORD_ENCRYPTED": false,
        "BACKUP_RESTORE_MODE": "backup",
        "SHARED_LOCATION": "\\\\\\\\FILESERVER\\\\arcgisbackup\\\\webgisdr",
        "INCLUDE_SCENE_TILE_CACHES": false,
        "BACKUP_STORE_PROVIDER": "AmazonS3",
        "S3_ENCRYPTED": false,
        "S3_BUCKET": "<S3 bucket>",
        "S3_CREDENTIALTYPE": "IAMRole",
        "S3_REGION": "us-east-1"
      }
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::webgisdr_export]"
  ]
}
```

### webgisdr_import

Restores ArcGIS Enterprise from backup using WebGISDR utility.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "run_as_user": "acrgis",
    "run_as_password": "<run_as_password>",
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal",
      "webgisdr_timeout": 36000,      
      "webgisdr_properties": {
        "PORTAL_ADMIN_URL": "https://domain.com:7443/arcgis",
        "PORTAL_ADMIN_USERNAME": "sitedmin",
        "PORTAL_ADMIN_PASSWORD": "<password>",
        "PORTAL_ADMIN_PASSWORD_ENCRYPTED": false,
        "BACKUP_RESTORE_MODE": "backup",
        "SHARED_LOCATION": "\\\\\\\\FILESERVER\\\\arcgisbackup\\\\webgisdr",
        "INCLUDE_SCENE_TILE_CACHES": false,
        "BACKUP_STORE_PROVIDER": "AmazonS3",
        "S3_ENCRYPTED": false,
        "S3_BUCKET": "<S3 bucket>",
        "S3_CREDENTIALTYPE": "IAMRole",
        "S3_REGION": "us-east-1"
      }
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::webgisdr_import]"
  ]
}
```

### webstyles

Installs ArcGIS WebStyles.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
   "version":"11.3",
    "webstyles": {
      "setup":"C:\\ArcGIS\\11.3\\Setups\\ArcGIS 11.3\\ArcGISWebStyles\\Setup.exe"
    }
  },
  "run_list": [
    "recipe[arcgis-enterprise::webstyles]"
  ]
}
```
