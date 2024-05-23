#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webadaptor
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

default['arcgis']['web_adaptor'].tap do |web_adaptor|

  web_adaptor['admin_access'] = false
  web_adaptor['install_system_requirements'] = true
  web_adaptor['setup_archive'] = ''
  web_adaptor['product_codes'] = []
  web_adaptor['patches'] = []

  case node['platform']
  when 'windows'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       "ArcGIS #{node['arcgis']['version']}",
                                       'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']
    web_adaptor['install_dir'] = ''
    web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles(x86)'],
                                                        'ArcGIS\\WebAdaptor\\IIS',
                                                        node['arcgis']['version'],
                                                        'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

    case node['arcgis']['version']
    when '11.3'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_113_190234.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{6D1FDF29-5DAB-4816-9CDE-15CF663E3BDD}', '{9DA66832-790E-4A08-90D8-3305D2C4F2A2}',
        '{E3DF9FCC-2078-4816-B195-EE30D1C74086}', '{87C9FEB8-73A7-436A-861E-74C3A3D7805B}',
        '{3D881639-2227-4E9E-9380-C55991C92D3F}', '{7FB27776-2537-456E-BF4D-6E90B1050E16}',
        '{013D126B-0E28-4070-B57D-1C7128511E09}', '{F2D44D27-A3EB-4892-A260-7FF8D90AE3ED}',
        '{AC6ECF31-E1D9-4A08-B7E2-9BF4EA138BFD}', '{D2B275D6-F12D-4AB1-B0E3-7E72E42309F6}',
        '{8AC70A2E-6E62-47C1-8DAE-63481CF7E570}', '{1C94E9C9-8FE0-4647-B679-1C99721D8E5A}',
        '{36E80F76-A84A-4C2E-9087-F6B6FC60B8F0}', '{442DAF3B-289D-45AC-855D-CD1AF79AD046}',
        '{2F5AE3DF-9918-4BB3-ADAC-D6A02681E8C5}', '{B2775E94-5176-42F2-9161-C52EFD7BFFD5}',
        '{614151D0-B8AE-4D85-83B3-70AFA3961E1A}', '{C9DD2778-546E-4E27-AEC1-C51BCA198172}',
        '{BF09767E-0CB7-4DAF-9ABE-400EE03CB9D6}', '{72587C29-AB2F-42F4-AB8B-A54325CA7A71}',
        '{1FA8B39E-07B5-4EAE-BABD-1B121131FEB2}', '{CFE37EEE-9148-4A1D-904C-05EBD63345DA}',
        '{2C774E47-A888-4F31-8425-781628500874}', '{2F923C43-6CF5-44B7-A21F-AFDE607C417D}',
        '{112A5C83-2207-4B94-9829-7433E8B82A7E}', '{2EE1C0D5-4631-47B3-B77E-CA5062732BA4}',
        '{0D125A07-D3FE-4388-870A-0CAC77280683}', '{0155E162-901D-41DF-A260-AA8E6C833D9A}',
        '{20F7ABC9-CC0F-47DD-B3FB-AA3D70140F1D}', '{407A2E2C-F8D7-4900-9F68-442774F9DD9E}',
        '{E86311FF-9990-48CD-A04C-B3404FA5B395}', '{2CF5D03B-AD63-4BB4-A3C6-7FD1D595F810}',
        '{8F2FCF64-7190-45B8-8DC4-4DAB5ED83425}', '{8673E73F-83A3-4C29-8BAB-516394436BC0}',
        '{6B41E749-D67F-4975-A858-7EEB32532C12}', '{E953DD69-8BA7-4653-AFEE-622E42B77AE1}',
        '{457B6C44-9A92-4F31-A071-359E8F000A70}', '{44FE2519-ABD7-4557-BD59-A1717928C539}',
        '{0B7987AB-85E2-480C-B245-D4BECE95E8EB}', '{D5985070-E78C-4B9A-8075-929EE77AC4B0}',
        '{F5D192C7-104E-4524-9DE0-36B34216B999}', '{65B4454A-4C0E-4DF0-BC32-18552466B306}',
        '{8AE7199B-D50C-48AD-BB82-1C289443C4C1}', '{0FDDEF60-6FA8-4DA7-9E05-A8CC4A1C1C9B}',
        '{033430AD-8978-459F-8CDA-2FD49B67752B}', '{85BD45E5-25CB-4FED-BBAE-2AA34286E556}',
        '{E46DBEB4-628D-4DC6-BC13-32F42B6EF5F6}', '{D976C4CB-B3B6-43C9-87E9-F27E2BE826AE}',
        '{91869554-E02E-4AB1-956F-AC1B54AF2158}', '{A88F3595-7DC9-455C-813D-66C6C687A9D1}',
        '{44CAC131-3CA6-44A1-AFBD-3E083365D5F0}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 11.3\\Updates'

      # ASP.NET Core Runtime 8 Hosting Bundle and Web Deploy 3.6 are required by ArcGIS Web Adaptor IIS 6. 
      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/2a7ae819-fbc4-4611-a1ba-f3b072d4ea25/32f3b931550f7b315d9827d564202eeb/dotnet-hosting-8.0.0-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-8.0.0-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '11.2'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_112_188253.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{3F2DF3A0-0EB7-4DED-BA7F-A33B7B106252}', '{CAB137C6-98F0-4569-9484-719632E81CF6}',
        '{899B1E0C-4675-4E52-BFBC-4FFF69DBAF8E}', '{4DE50EC3-6CB8-4EE5-B634-1AE53499F6D4}',
        '{A0ABE60F-0E01-4D84-A08B-EE34EFF96584}', '{066DEFEE-E71D-42F5-859E-225825268720}',
        '{53A32CFB-A012-4546-9A7F-09E489442A0A}', '{34AD67CC-2BA2-4EAA-B2A5-777036B0104E}',
        '{08CF83CB-FC1E-4F7C-8960-96C7D8A0B733}', '{D3803AB3-1C2F-4AD9-80EB-901685912599}',
        '{6671DEEE-CEE8-4FBD-B2DC-430F268225AF}', '{F92DED6B-B2B4-4E4F-A65B-ACE4973C0A9A}',
        '{6EDAB5E0-FD24-4427-82BE-134DB0FF9D37}', '{EFA6EC36-1A4B-481D-8A2E-C3B9098179F1}',
        '{CB1CA2A3-D209-462D-947A-AE5DCAACDC54}', '{D8D5A0CB-3F4F-4863-8EB2-6D24C0D0F093}',
        '{AE62DBD4-44A1-4E67-BAAC-4A5B2AC8830E}', '{8C323710-4026-4A8C-8DCF-5EFF6EE3F39B}',
        '{3232DC1F-00C3-4247-B354-FA022F1504C0}', '{3D0E95E1-BDA7-47BF-A967-3E889D3C79D9}',
        '{151724F6-2228-4A46-B710-88A6BAFEDCB4}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 11.2\\Updates'

      # ASP.NET Core Runtime 6 Hosting Bundle and Web Deploy 3.6 are required by ArcGIS Web Adaptor IIS 6. 

      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/eaa3eab9-cc21-44b5-a4e4-af31ee73b9fa/d8ad75d525dec0a30b52adc990796b11/dotnet-hosting-6.0.9-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-6.0.9-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '11.1'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_111_185222.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{E2F2DE02-86AC-42EE-B90D-544206717C9E}', '{A4082192-FA68-4150-8EB7-ACCF12F634C4}',
        '{7A467DB0-DE13-40A6-9213-7F336C28456E}', '{4C3342AC-45D7-417A-8DFC-54604649A97C}',
        '{8B8A2734-BEC8-476F-B99D-3E13C9F0BAA8}', '{62FCD139-C853-4944-809C-967835510785}',
        '{65E3E662-67D0-4608-A522-5C10C59CA2DC}', '{614E9ADA-CE81-44DB-BB04-C2A0E02C6458}',
        '{83F624D7-ED01-48A1-8E3A-6CEDD4CDEBF2}', '{F2D7F6E9-DB46-4B39-994A-FCA32EA5CF15}',
        '{4A6C5251-C1E3-4ADD-A442-773C110701E6}', '{E09C05F7-8E85-4402-A1A8-C53B6926D0CD}',
        '{5E664C01-5D5B-4CAA-A03F-145B69FFF6EA}', '{DC9156D0-13CE-4981-B0EB-3C55B1997632}',
        '{3A5F0EB2-B721-4E5F-9576-47F02A5F77F6}', '{09AFD321-FD2A-4D22-AEEB-C858E0691386}',
        '{B14810D6-F62D-4581-BBDB-80B739A504DB}', '{8A2CE94A-6340-4AA4-AE83-62A4FA8C5AC2}',
        '{90E8E4D4-DDE0-4743-AA83-CBDD1827F307}', '{7C10E922-35BD-4A1B-87B0-6346AF5D1462}',
        '{1EA1484D-962A-4923-9CD1-BC074031E25F}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 11.1\\Updates'

      # ASP.NET Core Runtime 6 Hosting Bundle and Web Deploy 3.6 are required by ArcGIS Web Adaptor IIS 6. 

      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/eaa3eab9-cc21-44b5-a4e4-af31ee73b9fa/d8ad75d525dec0a30b52adc990796b11/dotnet-hosting-6.0.9-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-6.0.9-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '11.0'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_110_182888.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{FCC01D4A-1159-41FC-BDB4-4B4E05B3436F}', '{920A1EFA-D4DC-4C6D-895A-93FDD1EDE394}',
        '{258F0D35-985B-4104-BCC4-B8F9A4BB89B4}', '{7B128234-C3D8-4274-917F-BC0BCE90887F}',
        '{CD160BB2-3AA9-42CE-8BA0-4BFF906E81DE}', '{BBBD3910-2CBB-4418-B5CE-FB349E1E74F0}',
        '{594D4267-E702-4BA8-9DF4-DB91DCF94B3E}', '{D2538F6E-E852-4BE0-9D20-61730D977410}',
        '{BAB5BA8A-DE70-4F79-9926-D6849C218BF2}', '{E37D4B50-05EC-4128-AC65-10E299693A3C}',
        '{2BD1FC31-CFB0-488A-83B3-BEC066423FAA}', '{AA378242-0C2C-4CC2-9E33-B44E0F92577C}',
        '{F00D0401-C60F-4AB1-BCF2-ADA00DF40AA9}', '{5AE7F499-C7A3-4477-BBED-3D8B21FF6322}',
        '{5147A262-75C3-4CAE-BCF0-09D9EBBF4A24}', '{7D3F3C7C-A40D-42EC-BA38-E04E6B3CFA16}',
        '{36305F97-388A-4427-AF76-C4BA8BC2A3DC}', '{BB3F184D-C512-4544-8A7D-76A1F600AEC2}',
        '{A4CEFD65-D3DF-4992-AC4A-2CED8894F0BF}', '{36B75654-E4C2-4FF3-B9F7-0D202D1ECAC8}',
        '{0E14FDF9-3D6C-48E4-B362-B248B61FC971}'
      ]
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 11.0\\Updates'
    when '10.9.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_1091_180055.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{BC399DA9-62A6-4978-9B75-32F46D3737F7}', '{F48C3ABF-AF5F-4326-9876-E748DB244DB7}',
        '{AC4AD5BF-E0B4-4EE6-838E-93EE66D986EF}', '{F96ECEFD-2015-4275-B15D-363F53407390}',
        '{21B1638E-47E7-4147-B739-EB341F99986F}', '{78ABEA6E-4832-4087-B7BB-04746D1E83E8}',
        '{A624163D-A110-4959-BD82-98CB7CE6ECBE}', '{7A6E0537-43A2-4925-8F8A-E19715B21392}',
        '{4AE1AE3D-2471-4393-B0D9-ECB4D1368EB9}', '{C72DE321-E19C-4737-9513-AE39B1A32953}',
        '{49F98C43-955D-4BD8-A585-07BA45D72D0A}', '{5DD68937-54F9-4015-A8DA-4602AFCA8986}',
        '{D3C16E17-DAB1-4025-A029-46C7598DCA4A}', '{A2CBD39F-C2DE-4983-9C70-7F108B52F402}',
        '{CA174887-E7C6-4DE9-8797-72CBD7FC4B1C}', '{B658575F-82ED-49BE-980C-D4A5089FCA7A}',
        '{CBEE526A-29B6-46FE-B7F8-B930A785CFF8}', '{76618450-9F2C-4FCC-9CDA-01A61F9E1953}',
        '{17591EF3-221C-4DD1-B773-6C9617925B5F}', '{566920BF-1EF3-4E62-B2BF-029475E35AAB}',
        '{4A3B27C6-7CB1-4DE8-BCB1-221B9A23E2E1}'
      ]
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 10.9.1\\Updates'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    end

    # Product codes used to uninstall ArcGIS Web Adaptor during upgrades.
    # The list includes the first two-four product codes form each supported ArcGIS version.
    web_adaptor['all_product_codes'] = [
      '{6D1FDF29-5DAB-4816-9CDE-15CF663E3BDD}', '{9DA66832-790E-4A08-90D8-3305D2C4F2A2}', # 11.3
      '{E3DF9FCC-2078-4816-B195-EE30D1C74086}', '{87C9FEB8-73A7-436A-861E-74C3A3D7805B}',
      '{3D881639-2227-4E9E-9380-C55991C92D3F}', '{7FB27776-2537-456E-BF4D-6E90B1050E16}',
      '{013D126B-0E28-4070-B57D-1C7128511E09}', '{F2D44D27-A3EB-4892-A260-7FF8D90AE3ED}',
      '{AC6ECF31-E1D9-4A08-B7E2-9BF4EA138BFD}', '{D2B275D6-F12D-4AB1-B0E3-7E72E42309F6}',
      '{8AC70A2E-6E62-47C1-8DAE-63481CF7E570}', '{1C94E9C9-8FE0-4647-B679-1C99721D8E5A}',
      '{36E80F76-A84A-4C2E-9087-F6B6FC60B8F0}', '{442DAF3B-289D-45AC-855D-CD1AF79AD046}',
      '{2F5AE3DF-9918-4BB3-ADAC-D6A02681E8C5}', '{B2775E94-5176-42F2-9161-C52EFD7BFFD5}',
      '{614151D0-B8AE-4D85-83B3-70AFA3961E1A}', '{C9DD2778-546E-4E27-AEC1-C51BCA198172}',
      '{BF09767E-0CB7-4DAF-9ABE-400EE03CB9D6}', '{72587C29-AB2F-42F4-AB8B-A54325CA7A71}',
      '{1FA8B39E-07B5-4EAE-BABD-1B121131FEB2}', '{CFE37EEE-9148-4A1D-904C-05EBD63345DA}',
      '{2C774E47-A888-4F31-8425-781628500874}', '{2F923C43-6CF5-44B7-A21F-AFDE607C417D}',
      '{112A5C83-2207-4B94-9829-7433E8B82A7E}', '{2EE1C0D5-4631-47B3-B77E-CA5062732BA4}',
      '{0D125A07-D3FE-4388-870A-0CAC77280683}', '{0155E162-901D-41DF-A260-AA8E6C833D9A}',
      '{20F7ABC9-CC0F-47DD-B3FB-AA3D70140F1D}', '{407A2E2C-F8D7-4900-9F68-442774F9DD9E}',
      '{E86311FF-9990-48CD-A04C-B3404FA5B395}', '{2CF5D03B-AD63-4BB4-A3C6-7FD1D595F810}',
      '{8F2FCF64-7190-45B8-8DC4-4DAB5ED83425}', '{8673E73F-83A3-4C29-8BAB-516394436BC0}',
      '{6B41E749-D67F-4975-A858-7EEB32532C12}', '{E953DD69-8BA7-4653-AFEE-622E42B77AE1}',
      '{457B6C44-9A92-4F31-A071-359E8F000A70}', '{44FE2519-ABD7-4557-BD59-A1717928C539}',
      '{0B7987AB-85E2-480C-B245-D4BECE95E8EB}', '{D5985070-E78C-4B9A-8075-929EE77AC4B0}',
      '{F5D192C7-104E-4524-9DE0-36B34216B999}', '{65B4454A-4C0E-4DF0-BC32-18552466B306}',
      '{8AE7199B-D50C-48AD-BB82-1C289443C4C1}', '{0FDDEF60-6FA8-4DA7-9E05-A8CC4A1C1C9B}',
      '{033430AD-8978-459F-8CDA-2FD49B67752B}', '{85BD45E5-25CB-4FED-BBAE-2AA34286E556}',
      '{E46DBEB4-628D-4DC6-BC13-32F42B6EF5F6}', '{D976C4CB-B3B6-43C9-87E9-F27E2BE826AE}',
      '{91869554-E02E-4AB1-956F-AC1B54AF2158}', '{A88F3595-7DC9-455C-813D-66C6C687A9D1}',
      '{44CAC131-3CA6-44A1-AFBD-3E083365D5F0}',
      '{3F2DF3A0-0EB7-4DED-BA7F-A33B7B106252}', '{CAB137C6-98F0-4569-9484-719632E81CF6}', # 11.2
      '{899B1E0C-4675-4E52-BFBC-4FFF69DBAF8E}', '{4DE50EC3-6CB8-4EE5-B634-1AE53499F6D4}',
      '{A0ABE60F-0E01-4D84-A08B-EE34EFF96584}', '{066DEFEE-E71D-42F5-859E-225825268720}',
      '{53A32CFB-A012-4546-9A7F-09E489442A0A}', '{34AD67CC-2BA2-4EAA-B2A5-777036B0104E}',
      '{08CF83CB-FC1E-4F7C-8960-96C7D8A0B733}', '{D3803AB3-1C2F-4AD9-80EB-901685912599}',
      '{6671DEEE-CEE8-4FBD-B2DC-430F268225AF}', '{F92DED6B-B2B4-4E4F-A65B-ACE4973C0A9A}',
      '{6EDAB5E0-FD24-4427-82BE-134DB0FF9D37}', '{EFA6EC36-1A4B-481D-8A2E-C3B9098179F1}',
      '{CB1CA2A3-D209-462D-947A-AE5DCAACDC54}', '{D8D5A0CB-3F4F-4863-8EB2-6D24C0D0F093}',
      '{AE62DBD4-44A1-4E67-BAAC-4A5B2AC8830E}', '{8C323710-4026-4A8C-8DCF-5EFF6EE3F39B}',
      '{3232DC1F-00C3-4247-B354-FA022F1504C0}', '{3D0E95E1-BDA7-47BF-A967-3E889D3C79D9}',
      '{151724F6-2228-4A46-B710-88A6BAFEDCB4}',
      '{E2F2DE02-86AC-42EE-B90D-544206717C9E}', '{A4082192-FA68-4150-8EB7-ACCF12F634C4}', # 11.1
      '{7A467DB0-DE13-40A6-9213-7F336C28456E}', '{4C3342AC-45D7-417A-8DFC-54604649A97C}',
      '{8B8A2734-BEC8-476F-B99D-3E13C9F0BAA8}', '{62FCD139-C853-4944-809C-967835510785}',
      '{65E3E662-67D0-4608-A522-5C10C59CA2DC}', '{614E9ADA-CE81-44DB-BB04-C2A0E02C6458}',
      '{83F624D7-ED01-48A1-8E3A-6CEDD4CDEBF2}', '{F2D7F6E9-DB46-4B39-994A-FCA32EA5CF15}',
      '{4A6C5251-C1E3-4ADD-A442-773C110701E6}', '{E09C05F7-8E85-4402-A1A8-C53B6926D0CD}',
      '{5E664C01-5D5B-4CAA-A03F-145B69FFF6EA}', '{DC9156D0-13CE-4981-B0EB-3C55B1997632}',
      '{3A5F0EB2-B721-4E5F-9576-47F02A5F77F6}', '{09AFD321-FD2A-4D22-AEEB-C858E0691386}',
      '{B14810D6-F62D-4581-BBDB-80B739A504DB}', '{8A2CE94A-6340-4AA4-AE83-62A4FA8C5AC2}',
      '{90E8E4D4-DDE0-4743-AA83-CBDD1827F307}', '{7C10E922-35BD-4A1B-87B0-6346AF5D1462}',
      '{1EA1484D-962A-4923-9CD1-BC074031E25F}',
      '{FCC01D4A-1159-41FC-BDB4-4B4E05B3436F}', '{920A1EFA-D4DC-4C6D-895A-93FDD1EDE394}', # 11.0
      '{258F0D35-985B-4104-BCC4-B8F9A4BB89B4}', '{7B128234-C3D8-4274-917F-BC0BCE90887F}',
      '{CD160BB2-3AA9-42CE-8BA0-4BFF906E81DE}', '{BBBD3910-2CBB-4418-B5CE-FB349E1E74F0}',
      '{594D4267-E702-4BA8-9DF4-DB91DCF94B3E}', '{D2538F6E-E852-4BE0-9D20-61730D977410}',
      '{BAB5BA8A-DE70-4F79-9926-D6849C218BF2}', '{E37D4B50-05EC-4128-AC65-10E299693A3C}',
      '{2BD1FC31-CFB0-488A-83B3-BEC066423FAA}', '{AA378242-0C2C-4CC2-9E33-B44E0F92577C}',
      '{F00D0401-C60F-4AB1-BCF2-ADA00DF40AA9}', '{5AE7F499-C7A3-4477-BBED-3D8B21FF6322}',
      '{5147A262-75C3-4CAE-BCF0-09D9EBBF4A24}', '{7D3F3C7C-A40D-42EC-BA38-E04E6B3CFA16}',
      '{36305F97-388A-4427-AF76-C4BA8BC2A3DC}', '{BB3F184D-C512-4544-8A7D-76A1F600AEC2}',
      '{A4CEFD65-D3DF-4992-AC4A-2CED8894F0BF}', '{36B75654-E4C2-4FF3-B9F7-0D202D1ECAC8}',
      '{0E14FDF9-3D6C-48E4-B362-B248B61FC971}',
      '{BC399DA9-62A6-4978-9B75-32F46D3737F7}', '{F48C3ABF-AF5F-4326-9876-E748DB244DB7}', # 10.9.1
      '{AC4AD5BF-E0B4-4EE6-838E-93EE66D986EF}', '{F96ECEFD-2015-4275-B15D-363F53407390}',
      '{21B1638E-47E7-4147-B739-EB341F99986F}', '{78ABEA6E-4832-4087-B7BB-04746D1E83E8}',
      '{A624163D-A110-4959-BD82-98CB7CE6ECBE}', '{7A6E0537-43A2-4925-8F8A-E19715B21392}',
      '{4AE1AE3D-2471-4393-B0D9-ECB4D1368EB9}', '{C72DE321-E19C-4737-9513-AE39B1A32953}',
      '{49F98C43-955D-4BD8-A585-07BA45D72D0A}', '{5DD68937-54F9-4015-A8DA-4602AFCA8986}',
      '{D3C16E17-DAB1-4025-A029-46C7598DCA4A}', '{A2CBD39F-C2DE-4983-9C70-7F108B52F402}',
      '{CA174887-E7C6-4DE9-8797-72CBD7FC4B1C}', '{B658575F-82ED-49BE-980C-D4A5089FCA7A}',
      '{CBEE526A-29B6-46FE-B7F8-B930A785CFF8}', '{76618450-9F2C-4FCC-9CDA-01A61F9E1953}',
      '{17591EF3-221C-4DD1-B773-6C9617925B5F}', '{566920BF-1EF3-4E62-B2BF-029475E35AAB}',
      '{4A3B27C6-7CB1-4DE8-BCB1-221B9A23E2E1}'
    ]
  else # node['platform'] == 'linux'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       node['arcgis']['version'],
                                       'WebAdaptor', 'Setup')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']

    case node['arcgis']['version']
    when '11.3'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_113_190319.tar.gz')
    when '11.2'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_112_188341.tar.gz')
    when '11.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_111_185233.tar.gz')
    when '11.0'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_110_182987.tar.gz')
    when '10.9.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_1091_180206.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    end

    web_adaptor['install_dir'] = '/'
    web_adaptor['install_subdir'] = "arcgis/webadaptor#{node['arcgis']['version']}"

    if node['arcgis']['web_adaptor']['install_dir'].nil?
      wa_install_dir = web_adaptor['install_dir']
    else
      wa_install_dir = node['arcgis']['web_adaptor']['install_dir']
    end

    if node['arcgis']['web_adaptor']['install_subdir'].nil?
      wa_install_subdir = web_adaptor['install_subdir']
    else
      wa_install_subdir = node['arcgis']['web_adaptor']['install_subdir']
    end

    web_adaptor['patch_log'] = ::File.join(wa_install_dir,
                                           wa_install_subdir,
                                           '.ESRI_WA_PATCH_LOG')
    
    web_adaptor['config_web_adaptor_sh'] = ::File.join(wa_install_dir,
                                                       wa_install_subdir,
                                                       'java/tools/configurewebadaptor.sh')                                           
  end

  web_adaptor['setup_options'] = ''

  # Starting from ArcGIS 10.8.1 Web Adaptor registration supports 'ReindexPortalContent' option.
  web_adaptor['reindex_portal_content'] = true
end
