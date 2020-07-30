#
# Cookbook Name:: arcgis-enterprise
# Provider:: gis_service
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
require 'fileutils'
require 'json'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

use_inline_resources

action :publish do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

  if !generate_token_url.nil? && !generate_token_url.empty?
    admin_client.generate_token_url = generate_token_url
  end

  if !admin_client.service_exists?(service)
    item_id = admin_client.upload_item(@new_resource.definition_file, 
                                       "Service definition file for #{@new_resource.name}.#{@new_resource.type}")

    service_configuration = JSON.parse(admin_client.extract_item_file(item_id, 'serviceconfiguration.json'))

    service_configuration['folderName'] = @new_resource.folder;
    service_configuration['service'] = service_configuration['service'].merge(@new_resource.properties)
    service_configuration['service']['serviceName'] = @new_resource.name
    service_configuration['service']['type'] = @new_resource.type

    publish_options = {}

    rest_client = ArcGIS::ServerRestClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

    rest_client.publish_service_definition(item_id,
                                           service_configuration,
                                           publish_options)

    new_resource.updated_by_last_action(true)
  end
end

action :add_permission do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

  if !generate_token_url.nil? && !generate_token_url.empty?
    admin_client.generate_token_url = generate_token_url
  end

  if admin_client.service_exists?(service)
    rest_client = ArcGIS::ServerRestClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

    @new_resource.roles.each do |role|
      rest_client.add_service_permission(@new_resource.name,
                                         @new_resource.type,
                                         role)
    end

    new_resource.updated_by_last_action(true)
  end
end

action :clean_permissions do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

  if !generate_token_url.nil? && !generate_token_url.empty?
    admin_client.generate_token_url = generate_token_url
  end

  rest_client = ArcGIS::ServerRestClient.new(@new_resource.server_url,
                                             @new_resource.username,
                                             @new_resource.password)

  @new_resource.roles.each do |role|
    rest_client.clean_service_permissions(role)
  end

  new_resource.updated_by_last_action(true)
end

action :upload_item do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

  if !generate_token_url.nil? && !generate_token_url.empty?
    admin_client.generate_token_url = generate_token_url
  end

  if admin_client.service_exists?(service)
    rest_client = ArcGIS::ServerRestClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

    rest_client.upload_service_item(@new_resource.name,
                                    @new_resource.type,
                                    @new_resource.item_folder,
                                    @new_resource.item_file)

    new_resource.updated_by_last_action(true)
  end
end

action :start do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  if admin_client.configured_service_state(service) == 'STARTED'
    # If service's configuredState is 'STARTED', wait until realTimeState becomes 'STARTED'.
    admin_client.wait_until_service_started(service)
  else
    admin_client.start_service(service)
  end

  new_resource.updated_by_last_action(true)
end

action :stop do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.stop_service(service)

  new_resource.updated_by_last_action(true)
end

action :delete do
  if @new_resource.folder.nil? || @new_resource.folder.empty? || @new_resource.folder == 'root'
    service = @new_resource.name + '.' + @new_resource.type;
  else
    service = @new_resource.folder + '/' + @new_resource.name + '.' + @new_resource.type;
  end

  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  if admin_client.service_exists?(service)
    admin_client.delete_service(service)

    new_resource.updated_by_last_action(true)
  end
end
