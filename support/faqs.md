---
layout: default
title: "FAQs"
category: support
item: faqs
latest: true
---

# FAQs

## Can I use Chef to upgrade ArcGIS Enterprise?

The Chef [deployment templates]({{ site.baseurl }}/templates.html) provide step-by-step instructions for upgrading ArcGIS Enterprise deployments that were initially created using older versions of the deployment templates.

Upgrading ArcGIS Enterprise deployments initially created using Chef Cookbooks for ArcGIS is also relatively straightforward. Usually it involves updating the machine role attributes used for the initial deployment to the new ArcGIS version, setups, and authorization files and running Chef on the deployment machines in a certain order. The upgrade may also require upgrading Chef client and cookbooks to new [versions]({{ site.baseurl }}/versions.html).  

If an ArcGIS Enterprise deployment was not initially created using Chef, it's possible to upgrade it using Chef; however, this requires setting all the machine role attributes to the values matching the actual deployment configuration. Setting all the attributes correctly in the first try is not easy. While there is nothing wrong with a trial-and-error approach for initial automated deployments, it's not suitable for in-place upgrades. For these reasons, it's not recommended to use Chef for an in-place upgrade if the Chef was not used for the initial deployment.

## Can I use Chef in a disconnected environment without access to the internet?

Yes you can. To use Chef Cookbooks for ArcGIS to deploy and configure ArcGIS in an environment where there is no internet connection available or internet access is prohibited by your organization, you will need to perform some steps on a machine that has internet access, and then transfer the files to a location accessible from the machines in the disconnected environment. You will also need to use software authorization files that support offline authorization.

## What is the difference between Chef Infra and CINC?

The goal of [CINC](https://cinc.sh/) project is to make [Chef Software Inc's](https://www.chef.io/) open source products easy for anyone to distribute it. Cinc Client is built from the Chef Infra™ Client [sources](https://github.com/chef/chef).

Chef Cookbooks for ArcGIS support Cinc Client as well as Chef Infra Client.

* The cinc-client tool can be used instead of chef-client.
* The cinc-solo tool can be used instead of chef-solo.
* The cinc-apply tool can be used instead of chef-apply.

## What is Chef Solo and Chef Zero?

The complete Chef Infra system configuration includes Chef Infra Workstation, Chef Infra Server, and Chef Infra Client. Chef Infra Client can also be run without Chef Infra Server. Chef Solo is a command that executes Chef Infra Client in a way that does not require the Chef Infra Server and does not support some functionality present in Chef Infra Client / Server configurations, such as centralized distribution of cookbooks and a centralized API.

Running Chef Infra Client in local mode behaves exactly like Chef Solo except that, during a run, it starts up a local Chef Zero server bound to localhost, uploads all local cookbooks and recipes to it, runs Chef Client, and then terminates the Chef Zero server. The end user experience is identical to chef-solo.

## Do I need to write code to use Chef Cookbooks for ArcGIS?  

In most cases, using Chef Cookbooks for ArcGIS does not require writing any code. You only need to edit JSON files. Writing code is only required for scenarios not supported by the cookbooks out-of-the-box.
