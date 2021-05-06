#
# Cookbook:: arcgis-repository
# Recipe:: s3files2
#
# Copyright 2020 Esri
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

# Create archives directory
directory node['arcgis']['repository']['local_archives'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

node['arcgis']['repository']['files'].each do |filename, props|
  # Download the remote file from S3
  s3_bucket = node['arcgis']['repository']['server']['s3bucket']
  s3_region = node['arcgis']['repository']['server']['region']
  s3_key = props['subfolder'].nil? ? filename : ::File.join(props['subfolder'], filename)
  path = ::File.join(node['arcgis']['repository']['local_archives'], filename)

  if node['platform'] == 'windows'
    keys = if node['arcgis']['repository']['server']['aws_access_key'].empty?
             '' # Use IAM role credentials
           else
             "-AccessKey #{node['arcgis']['repository']['server']['aws_access_key']} " \
             "-SecretKey #{node['arcgis']['repository']['server']['aws_secret_access_key']}"
           end

    powershell_script "Download #{filename}" do
      code "Read-S3Object -BucketName #{s3_bucket} -Region #{s3_region} -Key #{s3_key} -File #{path} #{keys}"
      not_if { ::File.exist?(::File.join(node['arcgis']['repository']['local_archives'], filename)) }
    end
  else
    keys = if node['arcgis']['repository']['server']['aws_access_key'].empty?
             {} # Use IAM role credentials
           else
             {'AWS_ACCESS_KEY_ID' => node['arcgis']['repository']['server']['aws_access_key'],
              'AWS_SECRET_ACCESS_KEY' => node['arcgis']['repository']['server']['aws_secret_access_key']}
           end

    execute "Download #{filename}" do
      command "aws s3 cp s3://#{s3_bucket}/#{s3_key} #{path} --region #{s3_region} --no-progress"
      environment keys
      not_if { ::File.exist?(::File.join(node['arcgis']['repository']['local_archives'], filename)) }
    end
  end
end
