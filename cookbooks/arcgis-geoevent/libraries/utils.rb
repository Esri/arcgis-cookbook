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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/registry'
end

#
# Utilities used by various arcgis cookbook resources.
#
module Utils
  MAX_RETRIES = 30
  SLEEP_TIME = 10.0

  def self.wait_until_url_available(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 600

    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    MAX_RETRIES.times do
      begin
        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field('Accept-Language', 'en-US')
        response = http.request(request)

        if response.code.to_i < 400
          Chef::Log.info("URL #{url} is available.")
          break
        end

        Chef::Log.debug("URL #{url} is not yet available. HTTP response code = #{response.code} (#{response.message})")
      rescue Exception => ex
        Chef::Log.debug("URL #{url} is not yet available. #{ex.message}")
      end

      sleep(SLEEP_TIME)
    end
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

  def self.retry_ShellOut(command, retries, retry_delay, hash = {})
    for i in 1..retries
      cmd = Mixlib::ShellOut.new(command, hash)
      cmd.run_command

      return cmd.exitstatus unless cmd.error?

      cmd.error! if i == retries

      sleep(retry_delay)
    end
  end

end
