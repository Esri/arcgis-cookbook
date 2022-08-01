---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
title: "Overview"
category: overview
item: index
latest: true
order: 1
---

# Overview

Automation of ArcGIS configuration management operations such as initial deployments, upgrades, and disaster recovery improves operational excellence, security, and reliability of ArcGIS deployments. Leveraging IT automation tools provides a platform for automation of ArcGIS operations that follows the industry's best practices.

[Chef Infra](https://docs.chef.io/chef_overview/) is a powerful automation platform that transforms infrastructure into code. Whether you’re operating in the cloud, on-premises, or in a hybrid environment, Chef Infra automates how infrastructure is configured, deployed, and managed across your network, no matter its size.

[Chef cookbook](https://docs.chef.io/cookbooks/) is the fundamental unit of configuration and policy distribution in Chef Infra that defines a scenario and contains everything that is required to support that scenario: recipes, attribute values, custom resources, files, and templates. Recipes specify which Chef Infra built-in resources to use, as well as the order in which they are to be applied. Attribute values allow environment-based configurations such as dev or production.

*Chef Cookbooks for ArcGIS* is a collection of Chef [cookbooks]({{ site.baseurl }}/cookbooks.html) for configuration, deployment, and management of ArcGIS Enterprise, ArcGIS Pro, and ArcGIS Desktop.

ArcGIS [deployment templates]({{ site.baseurl }}/templates.html) provide ready-to-use Chef JSON files for deploying ArcGIS with Chef. The JSON files are specific to ArcGIS versions, platforms, and machine roles. The deployment templates provide a straightforward and deterministic way to automate initial deployments and upgrades of ArcGIS Enterprise on-premises and in the cloud.
