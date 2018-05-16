include_attribute 'arcgis-enterprise::default'

default['arcgis']['sql_server_client'].tap do |client| 
  case node['platform']
  when 'windows'
    client['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'], 'Microsoft_ODBC_Driver_131_SQL_Server_64bit_157967.exe')
	client['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS 3rd Party',
                                  'ODBC131SQLServer_64', 'msodbcsql.msi').gsub('/', '\\')
  end
end