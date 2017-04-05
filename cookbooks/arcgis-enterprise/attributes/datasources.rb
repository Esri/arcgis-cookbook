include_attribute 'arcgis-enterprise::misc'

default['arcgis']['datasources'].tap do |datasource|
  datasource['block_data_copy'] = false
  datasource['ags_connection_file'] = File.join(node['arcgis']['misc']['script_directory'], 'AdminConnection.ags')
end