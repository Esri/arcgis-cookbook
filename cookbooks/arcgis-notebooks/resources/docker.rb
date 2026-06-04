#
# Cookbook Name:: arcgis-notebooks
# Resource:: docker
#
# Copyright 2025 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

actions :install, :restart

attribute :version, :kind_of => String
attribute :docker_repository_url, :kind_of => String, :default => 'https://download.docker.com'

def initialize(*args)
  super
  @action = :install
end

use_inline_resources if defined?(use_inline_resources)

action :install do
  case node['platform_family']
  when 'rhel', 'amazon'
    yum_repository 'docker' do
      baseurl "#{new_resource.docker_repository_url}/linux/rhel/#{node['platform_version'].to_i}/x86_64/stable"
      gpgkey "#{new_resource.docker_repository_url}/linux/rhel/gpg"
      description "Docker stable repository"
      gpgcheck true
      enabled true
    end  

    # Install Docker package
    package 'docker-ce' do
      version new_resource.version
      action :install
    end

    service 'docker' do
      action [:enable, :start]
    end
  when 'debian'
    apt_repository 'docker' do
      components ['stable']
      uri "#{new_resource.docker_repository_url}/linux/#{node['platform']}"
      arch 'amd64'
      key "#{new_resource.docker_repository_url}/linux/#{node['platform']}/gpg"
      # TODO: This eventually should go away once Debian 12 and Ubuntu 24.04 go EOL
      if node['platform_version'].to_f <= 24.04
        signed_by false
      end if Chef::VERSION >= Gem::Version.new('18.7.10')
    end  

    apt_update 'docker'

    version = version_string(new_resource.version)

    package 'docker-ce' do
      version version
      action :install
    end
  else
    Chef::Log.warn("Cannot setup the Docker repo for platform #{node['platform']}. Skipping.")
  end
end

action :restart do
  service 'docker' do
    action [:restart]
  end
end

def debuntu?
  return true if platform_family?('debian')
  false
end

def debian?
  return true if platform?('debian')
  false
end

def ubuntu?
  return true if platform?('ubuntu')
  false
end

def stretch?
  return true if platform?('debian') && node['platform_version'].to_i == 9
  false
end

def buster?
  return true if platform?('debian') && node['platform_version'].to_i == 10
  false
end

def bullseye?
  return true if platform?('debian') && node['platform_version'].to_i == 11
  false
end

def bookworm?
  return true if platform?('debian') && node['platform_version'].to_i == 12
  false
end

def bionic?
  return true if platform?('ubuntu') && node['platform_version'] == '18.04'
  false
end

def focal?
  return true if platform?('ubuntu') && node['platform_version'] == '20.04'
  false
end

def jammy?
  return true if platform?('ubuntu') && node['platform_version'] == '22.04'
  false
end

def noble?
  return true if platform?('ubuntu') && node['platform_version'] == '24.04'
  false
end

def version_string(v)
  return if v.nil?
  codename = if bionic? # ubuntu 18.04
               'bionic'
             elsif focal? # ubuntu 20.04
               'focal'
             elsif jammy? # ubuntu 22.04
               'jammy'
             elsif noble? # ubuntu 24.04
               'noble'
             end

  # https://github.com/seemethere/docker-ce-packaging/blob/9ba8e36e8588ea75209d813558c8065844c953a0/deb/gen-deb-ver#L16-L20
  test_version = '3'

  if v.to_f < 18.06 && !bionic?
    return "#{v}~ce-0~debian" if debian?
    return "#{v}~ce-0~ubuntu" if ubuntu?
  elsif v.to_f >= 23.0 && ubuntu?
    "5:#{v}-1~ubuntu.#{node['platform_version']}~#{codename}"
  elsif v.to_f >= 18.09 && debuntu?
    return "5:#{v}~#{test_version}-0~debian-#{codename}" if debian?
    return "5:#{v}~#{test_version}-0~ubuntu-#{codename}" if ubuntu?
  else
    return "#{v}~ce~#{test_version}-0~debian" if debian?
    return "#{v}~ce~#{test_version}-0~ubuntu" if ubuntu?
    v
  end
end
