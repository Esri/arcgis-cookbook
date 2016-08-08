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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/registry'
end

#
# Utilities used by arcgis-desktop cookbook resources.
#
module Utils

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

end
