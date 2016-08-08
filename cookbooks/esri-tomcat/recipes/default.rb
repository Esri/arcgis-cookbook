#
# Cookbook Name:: esri-tomcat
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'esri-tomcat::install'
include_recipe 'esri-tomcat::configure_ssl'
