# arcgis-egdb Deployment Template

Creates enterprise GeoDatabases in Amazon PostgreSQL RDS, Amazon Aurora with PostgreSQL compatibility, or SQL Server RDS and registers them with ArcGIS Server.

## System Requirements

The machines must have ArcGIS Server 10.9 installed and authorized. Consult the ArcGIS Server 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 15, or
* Cinc Client 15

### Recommended ArcGIS Chef Cookbooks versions

* 3.7.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
* Linux 
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7
  * CentOS Linux 8

SQL Server is only supported on Windows.

For Linux deployments enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following setups must be available in the ArcGIS software repository directory:

For Postgres on Windows

* ArcGIS_DataStore_Windows_109_177788.exe

For Postgres on Linux

* ArcGIS_DataStore_Linux_109_177887.tar.gz

For SQL Server (Windows only)

* VC_redist.x64.exe (will be downloaded if not found in the software repository)
* msodbcsql13.msi (will be downloaded if not found in the software repository)
* msodbcsql17.msi (will be downloaded if not found in the software repository)
* MsSqlCmdLnUtils.msi (will be downloaded if not found in the software repository)

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator/superuser using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-egdb cookbook README file.

## SQL Server RDS 

On primary ArcGIS Server machine

```
chef-client -z -j arcgis-egdb-rds-sqlserver-node.json
chef-client -z -j arcgis-egdb-rds-sqlserver.json
```

On all additional ArcGIS Server machines

```
chef-client -z arcgis-egdb-rds-sqlserver-node.json
```

## PostgreSQL RDS or Aurora with PostgreSQL

On primary ArcGIS Server machine

```
chef-client -z -j arcgis-egdb-rds-postgres.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-egdb deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## JSON Files Included in the Template

* arcgis-egdb-rds-postgres-s3files - downloads ArcGIS Data Store setups archives from S3 bucket
* arcgis-egdb-rds-sqlserver-s3files - downloads SQL Server ODBC drivers and command line utilities from S3 bucket
* arcgis-egdb-rds-postgres - Creates GeoDatabase in Amazon PostgreSQL RDS or Amazon Aurora with PostgreSQL compatibility and registers it with ArcGIS Server
* arcgis-egdb-rds-sqlserver - Creates GeoDatabases in SQL Server RDS and registers them with ArcGIS Server
* arcgis-egdb-rds-sqlserver-node - Installs SQL Server ODBC drivers and command line utilities

### arcgis-egdb-rds-postgres-s3files

Downloads ArcGIS Data Store setups files from S3 bucket to local ArcGIS software repository.

This role requires AWS Tools for PowerShell on Windows and AWS CLI on Ubuntu to be installed on the machine.  

### arcgis-egdb-rds-sqlserver-s3files

Downloads Microsoft Visual C++ 2017 Redistributable, SQL Server ODBC drivers, and SQL Command Line Utilities setups files from S3 bucket to local ArcGIS software repository.

This role requires AWS Tools for PowerShell on Windows and AWS CLI on Ubuntu to be installed on the machine.  

### arcgis-egdb-rds-postgres

Creates GeoDatabase 'egdb' in Amazon PostgreSQL RDS or Amazon Aurora with PostgreSQL compatibility and registers it with ArcGIS Server.

The role installs ralational ArcGIS Data Store to use its psql command line utility.

ArcGIS Server must be installed and authorized on the machines before running the role.

Required attributes:

* arcgis.egdb.endpoint - Postgres RDS server endpoint
* arcgis.egdb.master_username - Postgres RDS server master username
* arcgis.egdb.master_password - Postgres RDS server master user password
* arcgis.egdb.db_password - password of the database user (sde)
* arcgis.server.url - ArcGIS Server URL
* arcgis.server.admin_username - ArcGIS Server administrator username
* arcgis.server.admin_password - ArcGIS server administrator password

### arcgis-egdb-rds-sqlserver

Creates GeoDatabases in SQL Server RDS and registers them with ArcGIS Server.

ArcGIS Server, SQL Server ODBC drivers and command line utilities must must be installed and authorized on the machines before running the role.

Required attributes:

* arcgis.egdb.endpoint - SQL Server RDS server endpoint
* arcgis.egdb.master_username - SQL Server RDS server master username
* arcgis.egdb.master_password - SQL Server RDS server master user password
* arcgis.egdb.db_password - password of the database user (sde)
* arcgis.server.url - ArcGIS Server URL
* arcgis.server.admin_username - ArcGIS Server administrator username
* arcgis.server.admin_password - ArcGIS server administrator password

### arcgis-egdb-rds-sqlserver-node

Installs SQL Server ODBC drivers and command line utilities.
