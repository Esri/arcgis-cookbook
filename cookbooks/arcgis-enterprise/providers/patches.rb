action :install do
  # Dir.glob() doesn't support backslashes within a path, so they will be replaces on Windows
  if node['platform'] == 'windows'
    patch_folder = node["arcgis"]["patches"]["local_patch_folder"].gsub('\\','/')
  else
    patch_folder = node["arcgis"]["patches"]["local_patch_folder"]
  end

  # get all patches  within the specified folder and register them
  Dir.glob("#{patch_folder}/**/*").each do |patch|
    windows_package "Install #{patch}" do
      action :install
      source patch
      installer_type :custom
      options '/qn'
    end
  end
end