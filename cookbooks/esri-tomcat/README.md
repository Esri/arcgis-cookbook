---
layout: default
title: "esri-tomcat cookbook"
category: cookbooks
item: esri-tomcat
version: 0.3.1
latest: true
---

# esri-tomcat cookbook

This cookbook installs and configures Apache Tomcat for use with ArcGIS Web Adaptor.

## Supported Platforms

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

* tomcat
* openssl

## Attributes

### General

* `node['tomcat']['version']` = Tomcat version to install. Default is `9.0.83`.
* `node['tomcat']['instance_name']` = Tomcat instance name. Default is `arcgis`.
* `node['tomcat']['install_path']` = Tomcat installation directory. Default is `/opt/tomcat_INSTANCENAME_VERSION`.
* `node['tomcat']['tarball_base_uri']` = The base URI to the apache mirror containing the tarballs. Default is `https://archive.apache.org/dist/tomcat/`.
* `node['tomcat']['checksum_base_uri']`  = The base URI to the apache mirror containing the md5 or sha512 file. Default URI is `https://archive.apache.org/dist/tomcat/`.
* `node['tomcat']['tarball_path']` = Tomcat tarball archive path. Default is `<Chef file cache path>/apache-tomcat-<tomcat version>.tar.gz`.
* `node['tomcat']['verify_checksum']` = Verify checksum of downloaded Tomcat tarball. Default value is `true`.
* `node['tomcat']['forward_ports']` = If set to `true`, default recipe includes the 'firewalld' or 'iptables' recipe. Default value is `true`.
* `node['tomcat']['firewalld']['init_cmd']` = The firewalld initialization command. The default command is `firewall-cmd --zone=public --permanent --add-port=0-65535/tcp`.
* `node['tomcat']['create_symlink']` = Create symlink at `node['tomcat']['symlink_path']` to `node['tomcat']['install_path']`. Default is `true`.
* `node['tomcat']['symlink_path']` = Full path to where the symlink will be created targeting `node['tomcat']['install_path']`. Default path is `/opt/tomcat_<instance name>`.
* `node['tomcat']['tomcat_user_shell']` = Shell of the tomcat user. Default is `/bin/false`.
* `node['tomcat']['create_user']` = Create the specified tomcat user within the OS. Default is `true`.
* `node['tomcat']['create_group']` = Create the specified tomcat group within the OS. Default is `true`.
* `node['tomcat']['user']` = User to run tomcat as. Default is `tomcat_<instance name>`.
* `node['tomcat']['group']` = Group of the tomcat user. Default is `tomcat_<instance name>`.

### SSL/TLS

* `node['tomcat']['keystore_file']` = Optional: Path to the keystore file. If not provided, a new file and a self-signed certificate will be created.
* `node['tomcat']['keystore_password']` = Optional: Password to the keystore.
* `node['tomcat']['ssl_enabled_protocols']` = SSL protocols of the HTTPS listener. Default is `TLSv1.3,TLSv1.2`.
* `node['tomcat']['domain_name']` = Domain name for generated self-signed SSL certificate. Default is `Fully Qualified Domain Name`.

### OpenJDK

* `node['java']['version']` = Major Java version. Default version is `11.0.21+9`.
* `node['java']['tarball_uri']` = JDK tarball URI. Default URI is `https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.21_9.tar.gz`.
* `node['java']['tarball_path']` = JDK tarball local path. Default path is `<file_cache_path>/OpenJDK11U-jdk_x64_linux_hotspot_11.0.21_9.tar.gz`.
* `node['java']['install_path']` = JDK installation path. Default path is `/opt`.

## Recipes

### configure_ssl

Configures the HTTPS listener in Apache Tomcat application server.

```JSON
{
  "tomcat": {
    "version" : "9.0.48",
    "instance_name" : "arcgis",
    "user": "tomcat_arcgis",
    "group": "tomcat_arcgis",
    "install_path" : "/opt/tomcat_arcgis_9.0.48",
    "keystore_type" : "PKCS12",
    "keystore_file" : "/tomcat_arcgis/conf/resources/sslcerts/sslcert.pfx",
    "keystore_password": "<password>",
    "domain_name": "domain.com",
    "ssl_enabled_protocols" : "TLSv1.2,TLSv1.1,TLSv1"
  },
  "run_list" : [
    "recipe[esri-tomcat::configure_ssl]"
  ]
}
```

> Note: If the specified keystore file does not exist, the recipe generates a self-signed SSL certificate for the specified domain.

### default

Installs Apache Tomcat and configures the HTTPS listener. If the `node['tomcat']['forward_ports']` attribute is true (default value), the recipe also configures port forwarding (80 to 8080 and 443 to 8443) using the iptables or firewalld recipes.

```JSON
{
  "tomcat": {
    "version" : "9.0.48",
    "instance_name" : "arcgis",
    "user": "tomcat_arcgis",
    "group": "tomcat_arcgis",
    "install_path" : "/opt/tomcat_arcgis_9.0.48",
    "keystore_type" : "PKCS12",
    "keystore_file" : "/tomcat_arcgis/conf/resources/sslcerts/sslcert.pfx",
    "keystore_password": "<password>",
    "domain_name": "domain.com",
    "ssl_enabled_protocols" : "TLSv1.2,TLSv1.1,TLSv1",
    "tarball_path": "/opt/software/archives/apache-tomcat-9.0.48.tar.gz",
    "forward_ports": true
  },
  "run_list" : [
    "recipe[esri-tomcat]"
  ]
}
```

> Note: If the specified keystore file does not exist, the recipe generates a self-signed SSL certificate for the specified domain.

### firewalld

Configures port forwarding (80 to 8080 and 443 to 8443) using FirewallD.

> Note: If the firewalld service was started by the recipe, the recipe runs the script specified by node['tomcat']['firewalld']['init_cmd'], which, by default, opens all the TCP ports on the machine.

```JSON
{
  "tomcat": {
    "firewalld": {
      "init_cmd": "firewall-cmd --zone=public --permanent --add-port=0-65535/tcp"
    }
  },
  "run_list" : [
    "recipe[esri-tomcat::firewalld]"
  ]
}
```

### install

Installs Apache Tomcat application server.

```JSON
{
  "tomcat": {
    "version" : "9.0.48",
    "instance_name" : "arcgis",
    "user": "tomcat_arcgis",
    "group": "tomcat_arcgis",
    "install_path" : "/opt/tomcat_arcgis_9.0.48",
    "tarball_path": "/opt/software/archives/apache-tomcat-9.0.48.tar.gz"
  },
  "run_list" : [
    "recipe[esri-tomcat::install]"
  ]
}
```

### iptables

Configures port forwarding (80 to 8080 and 443 to 8443) using iptables.

```JSON
{
  "run_list" : [
    "recipe[esri-tomcat::iptables]"
  ]
}
```

### openjdk

Installs OpenJDK for Apache Tomcat from a local or remote tarball.

```JSON
{
  "java": {
    "version": "11",
    "tarball_path": "/opt/software/archives/openjdk-11_linux-x64_bin.tar.gz"
  },
  "run_list": [
    "recipe[esri-tomcat::openjdk]"
  ]
}
```
