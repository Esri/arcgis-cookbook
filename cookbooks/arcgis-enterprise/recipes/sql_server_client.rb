arcgis_enterprise_sql_server_client 'Unpack Microsoft ODBC Driver for SQL Server' do
  setup_archive node['arcgis']['sql_server_client']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['sql_server_client']['setup_archive']) &&
            !::File.exist?(node['arcgis']['sql_server_client']['setup']) }
  action :unpack
end

arcgis_enterprise_sql_server_client 'Install Microsoft ODBC Driver for SQL Server' do
  setup node['arcgis']['sql_server_client']['setup']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['sql_server_client']['setup']) }
  action :install
end