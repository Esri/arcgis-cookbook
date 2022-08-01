---
layout: default
title: "arcgis-egdb template"
category: templates
item: arcgis-egdb
version: 10.9.1
latest: false
---

# arcgis-egdb Deployment Template

Creates an enterprise geodatabase in PostgreSQL on Amazon Relational Database Service (RDS), Amazon Aurora with PostgreSQL compatibility, or SQL Server on Amazon RDS, and registers it with ArcGIS Server.

## System Requirements

The machines must have ArcGIS Server 10.9.1 installed and authorized. Consult the ArcGIS Server 10.9.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux 
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7

SQL Server is only supported zif you register with ArcGIS Server on Windows.

If you will register the geodatabase with ArcGIS Server on Linux, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following setups must be available in the ArcGIS software repository directory:

For geodatabases in PostgreSQL registered with ArcGIS Server on Windows

* ArcGIS_DataStore_Windows_1091_180054.exe

For geodatabases in PostgreSQL registered with ArcGIS Server on Linux

* ArcGIS_DataStore_Linux_1091_180204.tar.gz

For geodatabases in SQL Server (Windows only)

* VC_redist.x64.exe (will be downloaded if not found in the software repository)
* msodbcsql13.msi (will be downloaded if not found in the software repository)
* msodbcsql17.msi (will be downloaded if not found in the software repository)
* MsSqlCmdLnUtils.msi (will be downloaded if not found in the software repository)

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on machines as administrator/superuser using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-egdb cookbook README file.

## SQL Server on RDS 

On the primary ArcGIS Server machine

```
chef-client -z -j arcgis-egdb-rds-sqlserver-node.json
chef-client -z -j arcgis-egdb-rds-sqlserver.json
```

On all additional ArcGIS Server machines

```
chef-client -z arcgis-egdb-rds-sqlserver-node.json
```

## PostgreSQL on RDS or Aurora with PostgreSQL

On the primary ArcGIS Server machine

```
chef-client -z -j arcgis-egdb-rds-postgres.json
```


## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-egdb-rds-postgres-s3files

Downloads ArcGIS Data Store setup files from an S3 bucket to a local ArcGIS software repository.

This role requires AWS Tools for PowerShell on Windows and AWS CLI on Ubuntu to be installed on the machine.  

### arcgis-egdb-rds-sqlserver-s3files

Downloads Microsoft Visual C++ 2017 Redistributable, SQL Server ODBC drivers, and SQL Command Line Utilities setup files from an S3 bucket to a local ArcGIS software repository.

This role requires AWS Tools for PowerShell on Windows and AWS CLI on Ubuntu to be installed on the machine.  

### arcgis-egdb-rds-postgres

Creates a geodatabase 'egdb' in PostgreSQL on Amazon RDS or Amazon Aurora with PostgreSQL compatibility and registers it with ArcGIS Server.

The role installs a relational ArcGIS Data Store to use its psql command line utility.

ArcGIS Server must be installed and authorized on the machines before running the role.

Required attributes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.egdb.endpoint - Postgres RDS server endpoint
* arcgis.egdb.master_username - Postgres RDS server master username
* arcgis.egdb.master_password - Postgres RDS server master user password
* arcgis.egdb.db_password - Password of the database user (sde)
* arcgis.server.url - ArcGIS Server URL
* arcgis.server.admin_username - ArcGIS Server administrator username
* arcgis.server.admin_password - ArcGIS server administrator password

### arcgis-egdb-rds-sqlserver

Creates a geodatabases in SQL Server on RDS and registers it with ArcGIS Server.

ArcGIS Server, SQL Server ODBC drivers, and command line utilities must be installed, and ArcGIS Server must be authorized on the machines before running the role.

Required attributes:

* arcgis.egdb.endpoint - SQL Server RDS server endpoint
* arcgis.egdb.master_username - SQL Server RDS server master username
* arcgis.egdb.master_password - SQL Server RDS server master user password
* arcgis.egdb.db_password - Password of the database user (sde)
* arcgis.server.url - ArcGIS Server URL
* arcgis.server.admin_username - ArcGIS Server administrator username
* arcgis.server.admin_password - ArcGIS server administrator password

### arcgis-egdb-rds-sqlserver-node

Installs SQL Server ODBC drivers and command line utilities.
