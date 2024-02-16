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

require 'json'

#
# ArcGIS helper classes
#
module ArcGIS
  #
  # Helper class to invoke ArcGIS Data Store CLI tools.
  #
  class DataStoreTools

    # Tools execution timeouts
    CONFIGURE_SERVICE_ACCOUNT_TIMEOUT = 3600
    DESCRIBE_DATASTORE_TIMEOUT = 600
    CONFIGURE_BACKUP_LOCATION_TIMEOUT = 600
    CONFIGURE_DATASTORE_TIMEOUT = 10800
    PREPARE_UPGRADE_TIMEOUT = 600
    REMOVE_MACHINE_TIMEOUT = 600

    # Names of properties returned by describedatastore tool
    BACKUP_LOCATION = 'Backup location'

    @version = nil
    @platform = nil
    @tools_dir = nil
    @environment = nil
    @run_as_user = nil

    def initialize(version, platform, install_dir, install_subdir, run_as_user = nil)
      @version = version
      @platform = platform

      dir = platform == 'windows' ? install_dir : ::File.join(install_dir, install_subdir)

      @tools_dir = ::File.join(dir, 'tools')
      @environment = { 'AGSDATASTORE' => dir }
      @run_as_user = run_as_user
    end

    def configure_service_account(run_as_user, run_as_password)
      if @platform == 'windows'
        args = "--username \"#{run_as_user}\" --password \"#{run_as_password.gsub("&", "^&")}\""

        tool = ::File.join(@tools_dir, 'configureserviceaccount')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => CONFIGURE_SERVICE_ACCOUNT_TIMEOUT,
                                   :environment => @environment)

        cmd.run_command

        # Chef::Log.debug('STDOUT < ' + cmd.stdout)
        # Chef::Log.debug('STDERR < ' + cmd.stderr)

        Utils.sensitive_command_error(cmd, [ run_as_password.gsub("&", "^&") ])
      end
    end

    def last_known_status(data_dir)
      tilecache_config_json = ::File.join(data_dir, 'etc', 'tilecache-config.json')

      if ::File.exist?(tilecache_config_json)
        config = JSON.parse(File.read(tilecache_config_json))
        return config['localstore.lastknownstatus'] if config.has_key?('localstore.lastknownstatus')
      end

      nil
    end

    def configure_datastore(stores, server_url, username, password, data_dir, mode = nil)
      args = "\"#{server_url}\" \"#{username}\" \"#{password}\" \"#{data_dir}\" --stores #{stores}"

      # Add --mode parameter for post 10.8.1 tilecache and object data stores 
      # if the last known status is not 'Upgrading'.
      if !mode.nil? && !mode.empty? &&
         Gem::Version.new(@version.gsub(/\s+/, '-')) >= Gem::Version.new('10.8.1') &&
         stores.downcase.include?('tilecache') &&
         last_known_status(data_dir) != 'Upgrading'
        args += " --mode #{mode}"
      elsif !mode.nil? && !mode.empty? &&
        stores.downcase.include?('object') &&
        mode.downcase == 'cluster' &&
        last_known_status(data_dir) != 'Upgrading'
       args += " --mode cluster"
      end

      if @platform == 'windows'
        tool = ::File.join(@tools_dir, 'configuredatastore')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => CONFIGURE_DATASTORE_TIMEOUT,
                                   :environment => @environment)
      else
        tool = ::File.join(@tools_dir, 'configuredatastore.sh')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => CONFIGURE_DATASTORE_TIMEOUT,
                                   :user => @run_as_user)
      end

      cmd.run_command

      # Chef::Log.debug('STDOUT < ' + cmd.stdout)
      # Chef::Log.debug('STDERR < ' + cmd.stderr)

      Utils.sensitive_command_error(cmd, [ password ])
    end

    def describe_datastore(store)
      if @platform == 'windows'
        tool = ::File.join(@tools_dir, 'describedatastore')
        cmd = Mixlib::ShellOut.new("\"#{tool}\"",
                                   :timeout => DESCRIBE_DATASTORE_TIMEOUT,
                                   :environment => @environment)
      else
        tool = ::File.join(@tools_dir, 'describedatastore.sh')
        cmd = Mixlib::ShellOut.new("\"#{tool}\"",
                                   :timeout => DESCRIBE_DATASTORE_TIMEOUT,
                                   :user => @run_as_user)
      end

      cmd.run_command

      Chef::Log.debug('STDOUT < ' + cmd.stdout)
      Chef::Log.debug('STDERR < ' + cmd.stderr)

      cmd.error!

      properties = {}
      in_store = false

      # Parse the command stdout
      cmd.stdout.each_line do |line|
        if line.start_with?('Information for ')
          in_store = line.include?(display_store_name(store))
        elsif in_store && (line.length > 36) && !line.start_with?('=')
          key = line[0..35].delete!('.')
          value = line[36..-1].strip
          properties[key] = value
        end
      end

      properties
    end

    def backup_location(store)
      describe_datastore(store)[BACKUP_LOCATION]
    end

    def configure_backup_location(store, backup_location, operation)
      current_backup_location = backup_location(store)

      if !current_backup_location.nil? && Utils.same_file?(current_backup_location, backup_location)
        Chef::Log.info("#{store} backup location was not changed.")
        return
      end

      args = "--location \"#{backup_location}\" --operation #{operation} --store #{store} --prompt no"

      if @platform == 'windows'
        tool = ::File.join(@tools_dir, 'configurebackuplocation')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => CONFIGURE_BACKUP_LOCATION_TIMEOUT,
                                   :environment => @environment)
      else
        tool = ::File.join(@tools_dir, 'configurebackuplocation.sh')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => CONFIGURE_BACKUP_LOCATION_TIMEOUT,
                                   :user => @run_as_user)
      end

      cmd.run_command

      Chef::Log.debug('STDOUT < ' + cmd.stdout)
      Chef::Log.debug('STDERR < ' + cmd.stderr)

      if cmd.error? && cmd.stderr.include?('Operation is not supported under this configuration.')
        Chef::Log.debug(cmd.stderr)

        if operation != 'change' # prevent unlimited recursion
          configure_backup_location(store, backup_location, 'change')
        end
      elsif cmd.error? && cmd.stderr.include?('already exists')
        # Ignore the error if the backup location already exists.
        Chef::Log.debug(cmd.stderr)
      else
        cmd.error!
      end

      Chef::Log.info("#{store} backup location was changed to '#{backup_location}'.")
    end

    def prepare_upgrade(store, server_url, username, password, data_dir)
      args = "--server-url \"#{server_url}\" --server-admin \"#{username}\" --server-password \"#{password}\" --data-dir \"#{data_dir}\" --store \"#{store}\" --prompt no"

      if @platform == 'windows'
        tool = ::File.join(@tools_dir, 'prepareupgrade')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => PREPARE_UPGRADE_TIMEOUT,
                                   :environment => @environment)
      else
        tool = ::File.join(@tools_dir, 'prepareupgrade.sh')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => PREPARE_UPGRADE_TIMEOUT,
                                   :user => @run_as_user)
      end

      cmd.run_command

      # Chef::Log.debug('STDOUT < ' + cmd.stdout)
      # Chef::Log.debug('STDERR < ' + cmd.stderr)

      Utils.sensitive_command_error(cmd, [ password ])
    end

    def remove_machine(store, hostidentifier, force)
      args = "#{hostidentifier} --store #{store} --force #{force} --prompt no"

      if @platform == 'windows'
        tool = ::File.join(@tools_dir, 'removemachine')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => REMOVE_MACHINE_TIMEOUT,
                                   :environment => @environment)
      else
        tool = ::File.join(@tools_dir, 'removemachine.sh')
        cmd = Mixlib::ShellOut.new("\"#{tool}\" #{args}",
                                   :timeout => REMOVE_MACHINE_TIMEOUT,
                                   :user => @run_as_user)
      end

      cmd.run_command

      Chef::Log.debug('STDOUT < ' + cmd.stdout)
      Chef::Log.debug('STDERR < ' + cmd.stderr)

      cmd.error!
    end

    private

    def display_store_name(store)
      case store.downcase
      when 'relational'
        'relational'
      when 'tilecache'
        'tile cache'
      when 'spatiotemporal'
        'spatiotemporal'
      when 'object'
        'object'  
      else
        'undefined'
      end
    end
  end
end
