#
# Cookbook Name:: arcgis-enterprise
# Recipe:: disable_loopback_check
#
# Copyright 2021 Esri
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

 # Allow other machines to use filesharing via the DNS Alias (DisableStrictNameChecking)
 registry_key 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\lanmanserver\\parameters' do
    values [
      {
        name: 'DisableStrictNameChecking',
        type: :dword,
        data: 1,
      },
    ]
    action :create
  end

 #Allow server machine to use filesharing with itself via the DNS Alias (BackConnectionHostNames)
 registry_key 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0' do
    values [
      {
        name: 'BackConnectionHostNames',
        type: :multi_string,
        data: %w(FILESERVER),
      },
    ]
    action :create
  end