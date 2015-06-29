#
# Cookbook Name:: arcgis
# Recipe:: system
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

if platform?('windows')
  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    supports :manage_home => true
    password node['arcgis']['run_as_password']
    action :create
  end
  
  if node['platform_version'].to_f < 6.1
    #Windows Server 2008
    url = node['dotnetframework']['3.5.1']['url']
    if url != nil
      setup_exe = ::File.basename(url)
      setup_log_path = win_friendly_path(File.join(Dir.tmpdir(), "#{setup_exe}.html"))
      installer_cmd = "/q /norestart /log \"#{setup_log_path}\""
      
      windows_package "Microsoft .NET Framework" do
        source url 
        installer_type :custom
        options installer_cmd
        action :install
      end
    end
  elsif node['platform_version'].to_f < 6.2
    #Windows Server 2008 R2, Windows 7
      features = ["NetFx3"]
      
      features.each do |feature|
        windows_feature feature do
          action :install
        end
      end    
  elsif node['platform_version'].to_f < 6.3
    #Windows Server 2012, Windows 8
    features = ["NetFx3ServerFeatures", "NetFx3"]
    
    features.each do |feature|
      windows_feature feature do
        action :install
      end
    end    
  else
    #Windows Server 2012 R2, Windows 8.1
    features = ["IIS-WebServerRole"]
    
    features.each do |feature|
      windows_feature feature do
        action :install
      end
    end    
  end
else 
  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    supports :manage_home => true
    home '/home/' + node['arcgis']['run_as_user']
    action :create
  end

  set_limit node['arcgis']['run_as_user'] do
    type 'hard'
    item 'nofile'
    value 65535
    use_system true
  end
  
  set_limit node['arcgis']['run_as_user'] do
    type 'soft'
    item 'nofile'
    value 65535
    use_system true
  end
  
  set_limit node['arcgis']['run_as_user'] do
    type 'hard'
    item 'nproc'
    value 25059
    use_system true
  end
  
  set_limit node['arcgis']['run_as_user'] do
    type 'soft'
    item 'nproc'
    value 25059
    use_system true
  end
  
  #TODO: Test packages for each platform family 
  case node['platform']
  when 'redhat'
    ['mesa-libGLU', 'libXdmcp', 'xorg-x11-server-Xvfb'].each do |pckg|
      yum_package pckg do
        options '--enablerepo=*-optional'
        action :install
      end
    end

#    The following package groups are required.
#    
#    Red Hat Enterprise Linux Server 6 and 7
#    - dos2unix
#    - libSM
#    - libpng (rhel 6) / libpng12 (rhel 7)    
#    - fontconfig
#    - freetype
#    - libXfont
#    - mesa-libGL
#    - mesa-libGLU
#    - Xvfb
#    - X Window System package group 
#   For RHEL 6 Update 4 + xorg-x11-server patch information, see Red Hat Support and KB Article 42226.
#   For RHEL 5 Update 7 + libX11 patch information, see Red Hat Support.
#    
#    Red Hat Enterprise Linux Server 5
#    - dos2unix
#    - libSM6 (les 12)
#    - libpng12
#    - xorg-x11-libSM (les 11)        
#    - fontconfig
#    - freetype
#    - libXfont
#    - mesa-libGL
#    - mesa-libGLU
#    - X Window System package group
#    For RHEL 5 Update 7 + libX11 patch information, see Red Hat Support.
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package pckg do
        action :install
      end
    end

#    The following package groups are required.
#    
#    SUSE Linux Enterprise Server 12
#    - fontconfig
#    - libfreetype6
#    - libGLU1
#    - libXfont1
#    - Mesa-libGL1
#    - X Window System
#
#    SUSE Linux Enterprise Server 11
#    - fontconfig
#    - freetype2
#    - Mesa
#    - xorg-x11-libs
#    - X Window System
  else
    #NOTE: ArcGIS products are not officially supported on debian platform family
    ['xserver-common', 'xvfb', 'libfreetype6', 'libfontconfig1', 'libxfont1', 'libpixman-1-0',
     'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa', 'libpng12-0', 'x11-xkb-utils', 
     'libapr1', 'libxrender1', 'libxi6', 'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs'].each do |pckg|
      package pckg do
        action :install
      end
    end
  end
  
## Firewall settings
#  Portal for ArcGIS communicates on ports 7080, 7443, 7005, 7099, 7199, and 7654. You'll need to open these ports on your firewall before installing the software. For more information, see Ports used by Portal for ArcGIS.
#  Ports used by ArcGIS Server:  6080, 6443, 4000–4003,  4004 and above
#  Ports 1098, 6006, 6099, and other random ports are used by ArcGIS Server to start processes within each GIS server machine.
end  

