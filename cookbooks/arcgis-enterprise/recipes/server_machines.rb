unless node['arcgis']['server']['overwriteSocMaxHeapSize'].nil?
  arcgis_enterprise_server 'Set SOC Maximum Heap Size' do
    server_url node['arcgis']['server']['url']
    username node['arcgis']['server']['admin_username']
    password node['arcgis']['server']['admin_password']
    only_if { node['arcgis']['server']['overwriteSocMaxHeapSize'] }
    action :set_soc_max_heap_size
  end
end
