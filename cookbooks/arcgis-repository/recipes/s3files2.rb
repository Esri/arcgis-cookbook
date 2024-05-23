#
# Cookbook:: arcgis-repository
# Recipe:: s3files2
#
# Copyright 2024 Esri
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

include_recipe 'arcgis-repository::aws_cli'

# Create archives directory
directory node['arcgis']['repository']['local_archives'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

if node['arcgis']['repository']['server']['s3bucket'].empty?
  # Get S3 bucket name and AWS region from the ArcGIS Software Repository service info.
  repository = ArcGIS::RepositoryClient.new(node['arcgis']['repository']['server']['url'], nil, nil)
  repository_info = repository.info
  s3_bucket = repository_info['bucket']
  s3_region = repository_info['region']
else
  s3_bucket = node['arcgis']['repository']['server']['s3bucket']
  s3_region = node['arcgis']['repository']['server']['region']
end

aws_access_key = node['arcgis']['repository']['server']['aws_access_key']

env = if aws_access_key.nil? || aws_access_key.empty?
        {} # Use IAM role credentials
      else
        {'AWS_ACCESS_KEY_ID' => aws_access_key,
        'AWS_SECRET_ACCESS_KEY' => node['arcgis']['repository']['server']['aws_secret_access_key']}
      end

aws = node['platform'] == 'windows' ? 'aws' : ::File.join(node['arcgis']['repository']['aws_cli']['bin_dir'], 'aws')

node['arcgis']['repository']['files'].each do |filename, props|
  # Download the remote file from S3
  s3_key = props['subfolder'].nil? ? filename : ::File.join(props['subfolder'], filename)
  path = ::File.join(node['arcgis']['repository']['local_archives'], filename)

  execute "Download #{filename}" do
    command "#{aws} s3 cp s3://#{s3_bucket}/#{s3_key} #{path} --region #{s3_region} --no-progress"
    environment env
    not_if { ::File.exist?(::File.join(node['arcgis']['repository']['local_archives'], filename)) }
  end
end

# Download patches

patch_notification = node['arcgis']['repository']['patch_notification']
src = "s3://#{s3_bucket}/#{patch_notification['subfolder']}"
dst = node['arcgis']['repository']['local_patches']

filters = '--exclude "*"'

patch_notification['patches'].each do |patch|
  filters += " --include \"#{patch}\""
end

# Create patches directory
directory dst do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  not_if { patch_notification['subfolder'].nil? }  
  action :create
end

execute "Download ArcGIS patches from S3 repository" do
  command "#{aws} s3 cp #{src} #{dst} #{filters} --recursive --region #{s3_region} --no-progress"
  environment env
  live_stream true
  not_if { patch_notification['subfolder'].nil? }
end
