#
# Cookbook Name:: arcgis-enterprise
# Provider:: patches
#
# Copyright 2024 Esri
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

use_inline_resources if defined?(use_inline_resources)

action :install do
  # Dir.glob() doesn't support backslashes within a path, so they will be replaces on Windows.
  patch_file = ::File.join(@new_resource.patch_folder, @new_resource.patch).gsub('\\','/')
  patch_registry = @new_resource.patch_registry

  # Log a warning if the patch file does not exist or is not a file.
  if (!patch_file.include?('*') && !patch_file.include?('?')) &&
      (!::File.exist?(patch_file) || !::File.file?(patch_file))
    Chef::Log.warn("Patch file '#{patch_file}' does not exist.")
  end

  if node['platform'] == 'windows'
    # Get all windows patches within the specified file names and install them.
    # The file name may include wildcards like '*.msp'.
    Dir.glob(patch_file).each do |patch|
      windows_package patch do
        source patch
        installer_type :custom
        options '/qn'
        timeout 3600 # one hour
        not_if { Utils.windows_patch_installed?(patch, patch_registry) }
        action :install
      end
    end
  else
    # Get all linux patches within the specified folder and install them.
    Dir.glob(patch_file).each do |patch|
      if Utils.linux_patch_installed?(patch, @new_resource.patch_log)
        Chef::Log.info("Patch '#{patch}' is already installed.")
      else
        Chef::Log.info("Installing '#{patch}' patch...")
        
        Dir.mktmpdir do |repo|
          # Extract patch from the archive.
          if patch.end_with?('.gz')
            args = "xzvf \"#{patch}\" -C \"#{repo}\""
          else
            args = "xvf \"#{patch}\" -C \"#{repo}\""
          end

          cmd = Mixlib::ShellOut.new("tar #{args}", { :timeout => 360 })
          cmd.run_command
          cmd.error!

          run_as_user = @new_resource.run_as_user

          FileUtils.chown_R(run_as_user, nil, repo)

          # Run 'applypatch' script if it exists.
          Dir.glob("#{repo}/*/applypatch").each do |applypatch|
            args = "-s"
            args += " -#{@new_resource.product}" unless @new_resource.product.nil?
            
            Chef::Log.debug("\"#{applypatch}\" #{args}")

            if node['arcgis']['run_as_superuser']
              cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{applypatch} #{args}\"", 
                                        { :timeout => 3600 })
            else
              cmd = Mixlib::ShellOut.new("\"#{applypatch}\" #{args}", 
                                        {:user => run_as_user, :timeout => 3600 })
            end

            cmd.run_command

            if (cmd.error? && cmd.stdout.include?('This patch is already installed.'))
              Chef::Log.info(cmd.stdout)
            else
              cmd.error!
            end
          end

            # Run 'Patch.sh' script if it exists.
          Dir.glob("#{repo}/*/Patch.sh").each do |patch_sh|
            Chef::Log.debug("\"#{patch_sh}\"")

            if node['arcgis']['run_as_superuser']
              cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{patch_sh}\"", 
                                        { :timeout => 3600 })
            else
              cmd = Mixlib::ShellOut.new("\"#{patch_sh}\"", 
                                        {:user => run_as_user, :timeout => 3600 })
            end

            cmd.run_command

            if (cmd.error? && cmd.stdout.include?('this product is already installed.'))
              Chef::Log.info(cmd.stdout)
            else
              cmd.error!
            end
          end
        end

        new_resource.updated_by_last_action(true)
      end
    end
  end
end
