#
# Cookbook:: arcgis-repository
# Resource:: patches
#
# Copyright 2022 Esri
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

actions :download

attribute :patches_url, kind_of: String
attribute :products, kind_of: [Array, String]
attribute :versions, kind_of: [Array, String]
attribute :patches_dir, kind_of: String

def initialize(*args)
  super
  @action = :download
end

use_inline_resources if defined?(use_inline_resources)

action :download do
  patches_repo = ArcGIS::PatchesRepositoryClient.new(@new_resource.patches_url)

  patches_repo.download_patches(node['platform'], 
                                @new_resource.products,
                                @new_resource.versions,
                                @new_resource.patches_dir)
end
