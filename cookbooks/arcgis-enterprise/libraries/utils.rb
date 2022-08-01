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

require 'net/http'
require 'uri'
require 'json'
require 'pathname'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/registry'
  require 'win32ole'
end

#
# Utilities used by various arcgis cookbook resources.
#
module Utils
  MAX_RETRIES = 100
  SLEEP_TIME = 10.0

  def self.url_available?(url, redirects = 0)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 600

    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    begin
      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Accept-Language', 'en-US')
      response = http.request(request)

      Chef::Log.debug format('%s HTTP response code: %d', url, response.code.to_i)

      if redirects > 0 && response.code.to_i >= 300 && response.code.to_i < 400
        Chef::Log.debug format('Checking availability of redirected URL: %s', response['location'])
        return url_available?(response['location'], redirects - 1)
      end

      return response.code.to_i < 400
    rescue Exception => ex
      Chef::Log.debug ex.message
      return false
    end
  end

  def self.wait_until_url_available(url, redirects = 0)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    MAX_RETRIES.times do
      if url_available?(url, redirects)
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting
        Chef::Log.debug format('URL %s became available after %0.2f seconds.', url, elapsed)
        return
      end
      sleep(SLEEP_TIME)
    end

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting
    Chef::Log.warn format('Util.wait_until_url_available timed out for %s after %0.2f seconds.', url, elapsed)
  end

  def self.product_key_exists?(path)
    begin
      key = Win32::Registry::HKEY_LOCAL_MACHINE.open(path, ::Win32::Registry::KEY_READ | 0x100)
      display_name = key['DisplayName']
      key.close()
      return !display_name.nil?
    rescue
      return false
    end
  end

  def self.product_installed?(product_code)
    self.product_key_exists?('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\' + product_code) ||
    self.product_key_exists?('SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\' + product_code)
  end

  # Retrieves patch display name from MSP file
  def self.get_patch_info(msp_path)
    installer = WIN32OLE.new('WindowsInstaller.Installer')
    database = installer.OpenDatabase(msp_path, 32)
    summary = database.SummaryInformation
    return {
      :display_name => summary.Property(2),
      :qfe_id => summary.Property(3),
      :product_code => summary.Property(7),
      :patch_code => summary.Property(9)
    }
  end

  def self.windows_patch_installed?(msp_path, patch_registry)
    begin
      patch_info = self.get_patch_info(msp_path)

      if patch_registry.nil?
        key = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall', ::Win32::Registry::KEY_READ | 0x100)

        key.each_key() do |subkey|
          reg = key.open(subkey, ::Win32::Registry::KEY_READ | 0x100)
          
          begin
            if reg['DisplayName'] == patch_info[:display_name]
              reg.close()
              key.close()
              return true 
            end
          rescue
          end

          reg.close()
        end
    
        key.close()
      else # Look for the QFE ID in HKLM:\SOFTWARE\ESRI\* registry keys
        key = Win32::Registry::HKEY_LOCAL_MACHINE.open(patch_registry, ::Win32::Registry::KEY_READ | 0x100)

        key.each_key() do |subkey|
          reg = key.open(subkey, ::Win32::Registry::KEY_READ | 0x100)
          
          begin
            if reg['QFE_ID'] == patch_info[:qfe_id]
              reg.close()
              key.close()
              return true 
            end
          rescue
          end

          reg.close()
        end
    
        key.close()
      end
    rescue
    end

    return false
  end

  def self.linux_patch_installed?(patch_path, patch_log)
    return false if patch_log.nil? || !::File.exists?(patch_log)
    qfe_file = ::File.basename(patch_path)
    return ::File.open(patch_log).each_line.any? { |line| line.include?(qfe_file) }
  end

  def self.wa_instance(product_code)
    begin
      key = Win32::Registry::HKEY_LOCAL_MACHINE.open(
        'SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\' + product_code,
        ::Win32::Registry::KEY_READ | 0x100)
      install_location = Pathname.new(key['InstallLocation'])
      key.close()
      install_location.basename.to_s
    rescue
      return nil
    end
  end

  def self.wa_product_code(instance, product_codes)
    product_codes.each do |code|
      return code if wa_instance(code) == instance
    end
    return nil
  end

  def self.retry_ShellOut(command, retries, retry_delay, hash = {})
    for i in 1..retries
      cmd = Mixlib::ShellOut.new(command, hash)
      cmd.run_command

      return cmd.exitstatus unless cmd.error?

      cmd.error! if i == retries

      sleep(retry_delay)
    end
  end

  # Tests if the specified directory is read/write accessible for the specified user
  def self.directory_accessible?(dir, user, password)
    return false if dir.nil? || dir == '' || user.nil? || user == ''

    begin
      if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        cmd = Mixlib::ShellOut.new("dir \"#{dir}\"", {:user => user, :password => password, :timeout => 60})
        cmd.run_command
        exists = !cmd.error?

       if !exists
         cmd = Mixlib::ShellOut.new("mkdir \"#{dir}\"", {:user => user, :password => password, :timeout => 60})
         cmd.run_command
         cmd.error!

         cmd = Mixlib::ShellOut.new("rmdir \"#{dir}\"", {:user => user, :password => password, :timeout => 60})
         cmd.run_command
         cmd.error!
       else
         test_file = ::File.join(dir, "test.tmp")

         cmd = Mixlib::ShellOut.new("echo.>\"#{test_file}\"", {:user => user, :password => password, :timeout => 60})
         cmd.run_command
         cmd.error!

         cmd = Mixlib::ShellOut.new("del \"#{test_file}\"", {:user => user, :password => password, :timeout => 60})
         cmd.run_command
         cmd.error!
       end
      else
        cmd = Mixlib::ShellOut.new("ls #{dir}", {:user => user, :timeout => 60})
        cmd.run_command
        exists = !cmd.error?

       if !exists
         cmd = Mixlib::ShellOut.new("mkdir #{dir}", {:user => user, :timeout => 60})
         cmd.run_command
         cmd.error!

         cmd = Mixlib::ShellOut.new("rm #{dir}", {:user => user, :timeout => 60})
         cmd.run_command
         cmd.error!
       else
         test_file = ::File.join(dir, "test.tmp")

         cmd = Mixlib::ShellOut.new("touch #{test_file}", {:user => user, :timeout => 60})
         cmd.run_command
         cmd.error!

         cmd = Mixlib::ShellOut.new("rm #{test_file}", {:user => user, :timeout => 60})
         cmd.run_command
         cmd.error!
       end
      end
    rescue Exception => e
      Chef::Log.warn "Directory '#{dir}' is not accessible to user '#{user}'. " + e.message
      return false
    end

    Chef::Log.debug "Directory '#{dir}' is accessible to user '#{user}'. "
    return true
  end

  def self.wait_until_directory_accessible?(dir, user, password)
    MAX_RETRIES.times do
      break if self.directory_accessible?(dir, user, password)
      sleep(SLEEP_TIME)
    end
  end

  # Update windows service logon account
  def self.sc_config(service, user, password)
    if user.include? "\\"
      service_logon_user = user
    else
      service_logon_user = ".\\#{user}"
    end

    self.retry_ShellOut("sc.exe config \"#{service}\" obj= \"#{service_logon_user}\" password= \"#{password}\"",
                        1, 60, {:timeout => 600})

    if service_started?(service)
      self.retry_ShellOut("net stop \"#{service}\" /yes",  5, 60, :timeout => 3600)
      self.retry_ShellOut("net start \"#{service}\" /yes", 5, 60, :timeout => 600)
    end
  end

  # Changes windows service start-up type to auto
  def self.sc_enable(service)
    retry_ShellOut("sc.exe config \"#{service}\" start=auto", 1, 60, :timeout => 600)
  end

  # Returns true if windows service state is 'running' 
  def self.service_started?(service)
    return ::Win32::Service.status(service).current_state == 'running'
  end

  # Starts windows service and dependent services 
  def self.start_service(service)
    if !service_started?(service)
      retry_ShellOut("net start \"#{service}\" /yes", 5, 60, :timeout => 600)
    end
  end

  # Stops windows service and dependent services
  def self.stop_service(service)
    if service_started?(service)
      retry_ShellOut("net stop \"#{service}\" /yes", 5, 60, :timeout => 3600)
    end
  end

  def self.update_file_key_value(file, key, value)
    ##
    # Edit/update a config file with key=value settings
    # Remove all keys that are commented out
    # Remove all keys that do not match the specified value
    # Assumes there are no spaces between '=' sign
    ##
    fe = Chef::Util::FileEdit.new(file)

    # Different Value
    escaped_regex_key = Regexp.quote(key)
    fe.search_file_delete_line(/#{escaped_regex_key}=((?!#{value}).)*/)

    # Commented
    fe.search_file_delete_line("#(\s)*#{key}=")

    # Does not exist
    fe.insert_line_if_no_match("#{key}=#{value}", "#{key}=#{value}")

    fe.write_file
  end

  def self.file_key_value_updated?(file, key, value)
    ##
    # Should be used with update_file_key_value(file,key,value) as a guard for idempotency
    ##
    return ::File.open(file).each_line.any? { |line| line.chomp == "#{key}=#{value}" }
  end

  def self.same_file?(path1, path2)
    canonical_path1 = path1.nil? ? nil : path1.gsub('\\', '/').chomp('/')
    canonical_path2 = path2.nil? ? nil : path2.gsub('\\', '/').chomp('/')
    canonical_path1 == canonical_path2
  end

end
