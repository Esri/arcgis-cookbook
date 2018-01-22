#
# Copyright 2017 Esri
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

require 'java-properties'

# Utilities for reading '~/.ESRI.properties.<hostname>.<ArcGIS version>' file

module EsriProperties

  def self.esri_properties(user, hostname, arcgis_version)
    properties_file_path = "/home/#{user}/.ESRI.properties.*.#{arcgis_version}"

    cmd = Mixlib::ShellOut.new("cat #{properties_file_path}", { :user => user })
    cmd.run_command
    return {} if cmd.error?

    esri_properties = ::JavaProperties.parse(cmd.stdout)
  end

  # Returns installation directory for the specified ArcGIS product.
  # Valid product names are :ArcGISGeoEvent, :ArcGISServer, :ArcGISPortal, :ArcGISDataStore
  def self.product_install_dir(user, hostname, arcgis_version, product_name)
    esri_properties = self.esri_properties(user, hostname, arcgis_version)

    esri_properties["Z_#{product_name}_INSTALL_DIR".to_sym]
  end

  # Returns true if the the specified ArcGIS product is installed.
  # Valid product names are :ArcGISGeoEvent, :ArcGISServer, :ArcGISPortal, ArcGISDataStore
  def self.product_installed?(user, hostname, arcgis_version, product_name)
    !self.product_install_dir(user, hostname, arcgis_version, product_name).nil?
  end

  def self.real_version(user, hostname, arcgis_version) 
    esri_properties = self.esri_properties(user, hostname, arcgis_version)

    esri_properties[:Z_REAL_VERSION]
  end

  def self.license_home(user, hostname, arcgis_version) 
    esri_properties = self.esri_properties(user, hostname, arcgis_version)

    esri_properties[:ARCLICENSEHOME]
  end

end