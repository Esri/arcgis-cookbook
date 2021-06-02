#
# Cookbook Name:: arcgis-desktop
# Recipe:: licensemanager-set-port
#
# Copyright 2015 Esri
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

# Not sure if you are going to update license manager in the future but it 
# would be cool to have a recipe that allows the user to set static ports 
# for their firewall. I made one for N2W but I know yours would be a lot 
# better with parameters and such. 
# Also this was just build for Windows.
ruby_block 'Set static port after install' do
  block do
    file = Chef::Util::FileEdit.new('C:\\Program Files (x86)\\ArcGIS\\LicenseManager\\bin\\service.txt')
    file.search_file_replace_line(/^SERVER this_host/, 'SERVER this_host ANY 27000')
    file.search_file_replace_line(/^VENDOR ARCGIS/, 'VENDOR ARCGIS PORT=5152')
    file.write_file
  end
end

