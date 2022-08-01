---
layout: default
title: "Troubleshooting Tips"
category: support
item: troubleshooting
latest: true
---

# Troubleshooting Tips

If a Chef run failed, check the Chef run logs, fix the problem, and re-run Chef. Chef will skip the resources successfully completed by the previous runs and will retry running the failed resources.  

To enable detailed Chef run logs, change the Chef log level to debug. The debug log includes HTTP requests sent to ArcGIS Enterprise services, responses received from the services, and other detailed information about operations performed during the Chef run.

```shell
chef-client -z -j role.json -l debug
```

Consult [Chef Infra Client (executable)](https://docs.chef.io/ctl_chef_client/) documentation about configuring Chef log level and destination.

In case of runtime exceptions, the Chef client also writes the exception trace in the stacktrace.out file, and reports the file path in the Chef log.

## Common Problems

### Cannot load configuration

chef-solo may fail to load a configuration from a JSON file if the relative file path is used.

```shell
chef-solo -j .\filename.json
[2022-03-15T16:45:36-07:00] WARN: *****************************************
[2022-03-15T16:45:36-07:00] WARN: Did not find config file: C:/chef/client.rb. Using command line options instead.
[2022-03-15T16:45:36-07:00] WARN: *****************************************
[2022-03-15T16:45:36-07:00] FATAL: Cannot load configuration from .\filename.json
```

To workaround the problem, use the full path to the JSON file.

### No such cookbook

If a Chef run fails with the error "No such cookbook", it may indicate that either Chef is looking for the cookbooks in the wrong directory, or the cookbook directory does not contain the required cookbook.

To work around the problem, either change the current directory to the default Chef workspace directory or specify the cookbooks directory using a command line parameter.

```shell
chef-solo -j filename.json --config-option cookbook_path=C:\chef\cookbooks
```

> Note that the cookbooks archives in the arcgis-cookbook GitHub releases contain Chef cookbooks maintained by Esri and all the required dependent cookbooks, while the GitHub repository itself only contains Chef cookbooks maintained by Esri.

## Issues

Found a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).
