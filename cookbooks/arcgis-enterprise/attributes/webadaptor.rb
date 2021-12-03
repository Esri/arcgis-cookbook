#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webadaptor
#
# Copyright 2018 Esri
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
  web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe' 
  
  case node['platform']
  when 'windows'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       "ArcGIS #{node['arcgis']['version']}",
                                       'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']
    web_adaptor['install_dir'] = ''

    case node['arcgis']['version']
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
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.9.1\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.9'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_109_177789.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{1FD4759C-6858-42AD-A1DC-6DA0C3B1D28C}', '{E3CBD7DB-60AE-45F3-B281-F9556781E602}',
        '{D712233D-C35F-4A04-A7E8-6D3F00A40544}', '{D5EBAE28-7A5C-41E7-A04F-A1AAFF75C8AC}',
        '{2F798220-41AF-4D8D-B425-98095F3DC287}', '{06B94095-F4F9-4434-8358-2E84965B6301}',
        '{F2C06411-06A3-4617-8577-7975BD6CC32E}', '{10C21BB5-7E8C-47F6-AB6E-AC62300EA034}',
        '{B0D3E289-039D-470C-A9DC-1EB9713B2458}', '{35838A3A-D572-4B2B-8C83-4F8A99324F92}',
        '{CEEC063C-D280-490E-B795-373E7DE6266A}', '{4CB4458D-C08A-4DE8-9D0B-45C4E0B849F9}',
        '{83605278-1596-4C33-8484-CF2BD4C07587}', '{A2AE04B5-879C-4E0A-B237-D642D8BBE3C7}',
        '{38E1E357-BA81-4135-A11A-51FBC9C858DC}', '{947676E2-B5A6-49CB-A5AA-DFEB54D8F064}',
        '{8E838EF7-0B7D-4E2A-AF21-4639AC6E5492}', '{37913C5B-A6BA-4F1D-B12F-AD505B91D05A}',
        '{1C9C9C3C-CE4D-4F42-8A3B-78ECA6C57B8E}', '{0C000BEA-E770-4138-A707-CCB02E64469A}',
        '{D5CEFB24-D0FD-4C73-8685-205222E08C12}'
      ]
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.9\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.8.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_1081_175217.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{9695EF78-A2A8-4383-AFBF-627C55FE31DC}', '{56F26E70-2C61-45BC-A624-E100175086F7}',
        '{996B7BC1-3AF4-4633-AF5F-F7BE67448F51}', '{0FB565D2-7C0E-4723-B086-C67443ADE5FD}',
        '{246A7BFA-BE78-4031-A36D-F7BB95FFC5E2}', '{7D3E447C-3DB7-488D-AB11-C84A02476FF5}',
        '{1B5B7A25-F639-44F8-987B-6CD8F88967BE}', '{4242D730-262E-45E0-8E1F-9060F03452C3}',
        '{7CF4D730-F1D6-4D01-B750-D1BA7E55C3CC}', '{179DB6A6-DFE4-4AF1-92D5-2FDDD831A783}',
        '{0F67B656-1ED6-4C87-9DB3-DA51ABEE40C0}', '{86F8D877-87EA-4296-9D48-64D7AE94330B}',
        '{80FEB406-8086-42FE-B14B-C45A96B36894}', '{5990ACD0-4A80-4115-BFAE-F8DEB498A7C0}',
        '{12E78447-5AD7-41DB-82E5-BEDAAE7242C0}', '{25A1ECD8-4FAA-4271-9586-6FD94549365D}',
        '{221CCAE0-DA79-4C5E-ABCA-396E827334B1}', '{508FBAA8-FD44-4998-B797-1666BD41D804}',
        '{23EB5093-17EE-45A0-AE9F-C96B6456C15F}', '{BEB8559D-6843-4EED-A2ED-7BA9325EF482}',
        '{A12D63AE-3DE9-45A0-8799-F2BFF29A1665}'
      ]
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.8.1\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.8'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_108_172749.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [ 
        '{D6059C27-7199-4A94-806B-6C40EFD02828}', '{E77ED9CA-7DC8-45FC-A8BB-57AD2096EF8A}',
        '{068CA630-558A-4C4A-983F-ECF5F8183FC9}', '{F168EBD1-CEDA-469B-89E4-E79C85253CB6}',
        '{96229607-EC9D-4805-AF94-E1AC47676586}', '{D89375FD-6CAC-4204-8761-22F51B39E6A1}',
        '{BABA485F-681E-4B5D-95EF-54CC738F4A0C}', '{AEFE7DEE-1EEE-4F99-BCA7-2193B86C7058}',
        '{FC4B3333-7AEB-46C6-AD90-E071A18D653F}', '{119C0DB0-02B8-442C-B3F5-999D99C9D42F}',
        '{89946E15-3E27-4F13-946F-30205F18D34B}', '{5B21D9CD-DDC8-4768-88F6-3C0633E7B97E}',
        '{C0752042-FAAC-4A94-B5A4-918BE46B7595}', '{751ED05E-63BF-407C-9039-C72F33CC73D4}',
        '{720EDDD5-B0FD-4E53-8F80-0F328EA8ABE0}', '{5FBFC270-1AEE-4E41-B7A2-47F7C742EF95}',
        '{A46D3ECC-39D2-459C-9BC3-1C780CA5BCF1}', '{CAE80A6F-8046-47CE-B3F6-D2ACEDDDA99A}',
        '{0B5C6775-B1D2-4D41-B233-FC2CDC913FEE}', '{278663A9-7CA3-40D5-84EA-CA7A9CABACB6}',
        '{9452D085-0F4F-4869-B8B4-D660B4DD8692}'
      ]
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.8\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.7.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_1071_169690.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{5ECEF84F-592C-47D1-B7C5-9F3D7E2AB7CE}', '{5F1D01EA-296E-4226-A704-6A90E2916782}']
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.7.1\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.7'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_107_167634.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{F343B520-F769-4D93-86D2-663168AC6975}', '{58A76431-E1A9-4D11-BB89-0D12C6E77C78}']
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\10.7\\Tools\\ConfigureWebAdaptor.exe' 
    when '10.6.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_1061_163981.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{1B4E7470-72F4-4169-92B9-EF1BDF8AE4AF}', '{3FA8B44E-E0E3-4245-A662-6B81E1E75048}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.6'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_106_161833.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{4FB9D475-9A23-478D-B9F7-05EBA2073FC7}', '{38DBD944-7F0E-48EB-9DCB-98A0567FB062}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.5.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_1051_156367.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{0A9DA130-E764-485F-8C1A-AD78B04AA7A4}', '{B8A6A873-ED78-47CE-A9B4-AB3192C47604}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.5'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_105_154007.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{87B4BD93-A5E5-469E-9224-8A289C6B2F10}', '{604CF558-B7E1-4271-8543-75E260080DFA}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.4.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_1041_151933.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{F53FEE2B-54DD-4A6F-8545-6865F4FBF6DC}', '{475ACDE5-D140-4F10-9006-C804CA93D2EF}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.4'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_for_Microsoft_IIS_104_149435.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = ['{B83D9E06-B57C-4B26-BF7A-004BE10AB2D5}', '{E2C783F3-6F85-4B49-BFCD-6D6A57A2CFCE}']
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    end

    # Product codes used to uninstall ArcGIS Web Adaptor during upgrades.
    # The list includes the first two-four product codes form each supported ArcGIS version.
    web_adaptor['all_product_codes'] = [
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
      '{4A3B27C6-7CB1-4DE8-BCB1-221B9A23E2E1}',
      '{1FD4759C-6858-42AD-A1DC-6DA0C3B1D28C}', '{E3CBD7DB-60AE-45F3-B281-F9556781E602}', # 10.9
      '{D712233D-C35F-4A04-A7E8-6D3F00A40544}', '{D5EBAE28-7A5C-41E7-A04F-A1AAFF75C8AC}',
      '{2F798220-41AF-4D8D-B425-98095F3DC287}', '{06B94095-F4F9-4434-8358-2E84965B6301}',
      '{F2C06411-06A3-4617-8577-7975BD6CC32E}', '{10C21BB5-7E8C-47F6-AB6E-AC62300EA034}',
      '{B0D3E289-039D-470C-A9DC-1EB9713B2458}', '{35838A3A-D572-4B2B-8C83-4F8A99324F92}',
      '{CEEC063C-D280-490E-B795-373E7DE6266A}', '{4CB4458D-C08A-4DE8-9D0B-45C4E0B849F9}',
      '{83605278-1596-4C33-8484-CF2BD4C07587}', '{A2AE04B5-879C-4E0A-B237-D642D8BBE3C7}',
      '{38E1E357-BA81-4135-A11A-51FBC9C858DC}', '{947676E2-B5A6-49CB-A5AA-DFEB54D8F064}',
      '{8E838EF7-0B7D-4E2A-AF21-4639AC6E5492}', '{37913C5B-A6BA-4F1D-B12F-AD505B91D05A}',
      '{1C9C9C3C-CE4D-4F42-8A3B-78ECA6C57B8E}', '{0C000BEA-E770-4138-A707-CCB02E64469A}',
      '{D5CEFB24-D0FD-4C73-8685-205222E08C12}',
      '{9695EF78-A2A8-4383-AFBF-627C55FE31DC}', '{56F26E70-2C61-45BC-A624-E100175086F7}', # 10.8.1
      '{996B7BC1-3AF4-4633-AF5F-F7BE67448F51}', '{0FB565D2-7C0E-4723-B086-C67443ADE5FD}',
      '{246A7BFA-BE78-4031-A36D-F7BB95FFC5E2}', '{7D3E447C-3DB7-488D-AB11-C84A02476FF5}',
      '{1B5B7A25-F639-44F8-987B-6CD8F88967BE}', '{4242D730-262E-45E0-8E1F-9060F03452C3}',
      '{7CF4D730-F1D6-4D01-B750-D1BA7E55C3CC}', '{179DB6A6-DFE4-4AF1-92D5-2FDDD831A783}',
      '{0F67B656-1ED6-4C87-9DB3-DA51ABEE40C0}', '{86F8D877-87EA-4296-9D48-64D7AE94330B}',
      '{80FEB406-8086-42FE-B14B-C45A96B36894}', '{5990ACD0-4A80-4115-BFAE-F8DEB498A7C0}',
      '{12E78447-5AD7-41DB-82E5-BEDAAE7242C0}', '{25A1ECD8-4FAA-4271-9586-6FD94549365D}',
      '{221CCAE0-DA79-4C5E-ABCA-396E827334B1}', '{508FBAA8-FD44-4998-B797-1666BD41D804}',
      '{23EB5093-17EE-45A0-AE9F-C96B6456C15F}', '{BEB8559D-6843-4EED-A2ED-7BA9325EF482}',
      '{A12D63AE-3DE9-45A0-8799-F2BFF29A1665}',
      '{D6059C27-7199-4A94-806B-6C40EFD02828}', '{E77ED9CA-7DC8-45FC-A8BB-57AD2096EF8A}', # 10.8
      '{068CA630-558A-4C4A-983F-ECF5F8183FC9}', '{F168EBD1-CEDA-469B-89E4-E79C85253CB6}',
      '{96229607-EC9D-4805-AF94-E1AC47676586}', '{D89375FD-6CAC-4204-8761-22F51B39E6A1}',
      '{BABA485F-681E-4B5D-95EF-54CC738F4A0C}', '{AEFE7DEE-1EEE-4F99-BCA7-2193B86C7058}',
      '{FC4B3333-7AEB-46C6-AD90-E071A18D653F}', '{119C0DB0-02B8-442C-B3F5-999D99C9D42F}',
      '{89946E15-3E27-4F13-946F-30205F18D34B}', '{5B21D9CD-DDC8-4768-88F6-3C0633E7B97E}',
      '{C0752042-FAAC-4A94-B5A4-918BE46B7595}', '{751ED05E-63BF-407C-9039-C72F33CC73D4}',
      '{720EDDD5-B0FD-4E53-8F80-0F328EA8ABE0}', '{5FBFC270-1AEE-4E41-B7A2-47F7C742EF95}',
      '{A46D3ECC-39D2-459C-9BC3-1C780CA5BCF1}', '{CAE80A6F-8046-47CE-B3F6-D2ACEDDDA99A}',
      '{0B5C6775-B1D2-4D41-B233-FC2CDC913FEE}', '{278663A9-7CA3-40D5-84EA-CA7A9CABACB6}',
      '{9452D085-0F4F-4869-B8B4-D660B4DD8692}',
      '{5ECEF84F-592C-47D1-B7C5-9F3D7E2AB7CE}', '{5F1D01EA-296E-4226-A704-6A90E2916782}', # 10.7.1
      '{7368D3C8-F13B-4786-AE38-B51952F43867}', '{2C838C64-DF81-4A64-8618-072AD30D51C1}',
      '{D4054E1B-C75C-4F69-BBB7-DBE77250F345}', '{C2C75F23-3E15-43E4-A902-673569F3F0DF}',
      '{F633A04F-D08B-4EBF-B746-00ADA0334CE3}', '{7D13D8C5-751F-44B1-BEAE-C9EB8E13FDF8}',
      '{ACAA0479-B7C5-44A1-B5FD-34A018EA2137}', '{E0343824-0C94-4A6C-96F7-AA5E1D8F8437}',
      '{8D108926-DC71-493D-B2C9-8BAE04DD9047}', '{A19DF635-25F0-4371-AC42-A4EECAF8BD75}',
      '{78F54FC8-C530-4D7E-91CC-48B9BC364535}', '{CEFB5C80-707B-471A-B8BF-5EC333F1A8B2}',
      '{BE892BB6-842B-4A18-A0B7-E89C5AAAD1A3}', '{A11006D2-3C1A-4D56-917D-4417D3341ADD}',
      '{763E3951-E827-492B-8E86-F526F251083E}', '{57C506AE-3BB7-4936-9154-7A2744735456}',
      '{4E2BA3D3-EFD2-4FCE-91C0-1D15457F8F08}', '{1BBB3C99-8EF5-4225-B5DD-799E50582BF7}',
      '{F6E99E06-B303-4965-9566-2F21EE7FD130}',
      '{F343B520-F769-4D93-86D2-663168AC6975}', '{58A76431-E1A9-4D11-BB89-0D12C6E77C78}', # 10.7
      '{E7B9D4A3-4E55-49F8-B34C-CA8745FFD894}', '{D89709DB-8B6D-431A-95D4-FFEB69C474D5}',
      '{858283F5-B9E9-4688-BF3C-BD3F3FD169D8}', '{DE2BA579-D2F0-4068-9C52-8AC24022F13D}',
      '{48405A7D-CFA4-4F6F-BB8C-B36A22E99B07}', '{BEC99E10-7AB1-4B90-9C81-D2CBFCAD4239}',
      '{C0C178B9-EBC6-46C5-B009-186661E9AEA3}', '{0D5F9D8E-B221-4C74-87C3-13050F906A94}',
      '{52EC0A7A-9BBA-4F47-9C52-2E1D1D09D9B4}', '{6CF9C794-AEC2-45EF-A11A-83938F01A1E9}',
      '{F36AF2F5-2E37-409B-9E71-D2D2B1D4A22F}', '{4F54A93E-2F0F-4515-99AA-83BF88961D5F}',
      '{A04ACEF7-4E22-4F4F-8608-9FD335572C6F}', '{0D562427-2AB5-46C6-998E-4C33D642DE10}',
      '{8C15E459-D24F-46E0-B945-CD4812A040AC}', '{24821676-BD09-49CA-95B4-591BBE86118A}',
      '{3C4D06FD-8194-4062-AB04-E87003CBE908}', '{71044157-41F9-4AEC-B6B1-834FBA256135}',
      '{C4ECCD46-EC43-4C44-8147-916649A2BA1B}',
      '{1B4E7470-72F4-4169-92B9-EF1BDF8AE4AF}', '{3FA8B44E-E0E3-4245-A662-6B81E1E75048}', # 10.6.1
      '{8D6EE2C0-A393-49CD-A048-1D9FD435D7B8}', '{6C05375F-78A5-4DF7-A157-C2A6E0D7BAD2}',
      '{1F1EEC9F-80D5-48DD-B8BC-EB3D0404D9AD}', '{2CA5FC7F-1165-4870-9C16-004ACC848435}',
      '{E23D8BB8-0FEB-4316-8E09-80772FD1B5E0}', '{C67E73AB-8278-49C9-9CA8-A714E20B8124}',
      '{E527C0BD-E026-46D8-9461-2A7EEFBDA35A}', '{D5DF4279-E3FF-4261-AB85-93F8BDE90D8D}',
      '{8D439456-493A-4B48-A542-492AABD9CF7D}', '{D61CE1AE-2DB8-4D46-AC7F-3BEAB7C29A59}',
      '{9B07A4CE-58C6-4689-B37B-EFF565712CF2}', '{C97C2CEF-F939-496E-8CB7-8756856CBBC6}',
      '{59079961-A0BA-48DD-9B07-45437FCBC42A}', '{5372DAF1-7EB6-4822-843E-0B2F7A7B052B}',
      '{D807F4E9-0F87-4B3C-8F93-456251226187}', '{7BEB71AD-3958-41FB-8EC3-64DBE4775760}',
      '{286D4CB5-777E-4AA1-B2EB-D6A3A4212107}', '{37F3B528-915F-4528-949B-F199E4B3B4AA}',
      '{6FEB4C76-14AC-4A70-BE45-6CBAED529CAF}',
      '{4FB9D475-9A23-478D-B9F7-05EBA2073FC7}', '{38DBD944-7F0E-48EB-9DCB-98A0567FB062}', # 10.6
      '{8214B9D8-49D9-43DB-8632-AE2BAD4B21E9}', '{B3FD1FE3-4851-4657-9754-73876D4CB265}',
      '{88CDE5E9-23B8-4077-9E69-9CD3715BE805}', '{E7630CBC-96DE-4665-9C2A-D682CFFD5B0E}',
      '{E2601F84-D2E5-4DD4-B0EC-6AED75CB77D9}', '{75FB755F-AF36-484E-98A8-FADA56574D25}',
      '{AA32D01D-27CD-4842-90CF-F22C1BD6309B}', '{CF126207-4C89-44AA-8783-9BAA2BA5F106}',
      '{9F8694BE-613F-4195-AA42-B849E84D059A}', '{2C3BE00F-57BE-4D0B-81BC-3378D823CF0E}',
      '{EAC54B65-D6BC-41DC-8C82-5E99D7FD4271}', '{76C17CB6-106C-41F8-89BA-41C086E69238}',
      '{4493EB64-CAE0-439F-8FA6-897677D5A6C8}', '{0C59A27D-B4B6-4A23-8873-897B870F6E2B}',
      '{B46B6E63-D8E1-4EA4-9A9B-D98DFAA6644D}', '{89E6330E-6139-4F4B-BA9F-ACD59065230D}',
      '{238E647E-53DF-4B8B-B436-ADA5004065DE}', '{30EF8944-904A-45D3-96D4-7DF3B0FE01D5}',
      '{06012CC0-5C12-4499-B5CC-99E9D547A2FD}',
      '{0A9DA130-E764-485F-8C1A-AD78B04AA7A4}', '{B8A6A873-ED78-47CE-A9B4-AB3192C47604}', # 10.5.1
      '{7DEAE915-5FAC-4534-853D-B4FC968DBDEB}', '{AC10F3CF-A5C1-44B0-8271-27F26D323D14}',
      '{5F748B0C-3FB6-42FF-A82D-C1573D3C1469}', '{428DE39D-BF23-42B5-A70E-F5DD5DD21C2C}',
      '{98B1DE9B-0ECF-4CAA-A29A-B89B2E8F38F1}', '{4876508B-31CF-4328-BE11-FFF1B07A3923}',
      '{D803A89F-4762-4EFD-8219-55F4C3047EDE}', '{4A5F404B-391F-4D13-9EE4-5B9AC434FD5A}',
      '{99FFFA13-2A40-4AA4-AAC1-9891F2515DB1}', '{2B04DE60-3E79-4B44-9A93-40CAC72DE2FB}',
      '{D595C9E2-BBA0-4708-A871-1166CD0CFB61}', '{50825C57-5040-436D-B64C-A53FFB897E9D}',
      '{5D750A11-BC80-45CE-B0DD-33BA8A5D8224}', '{60390703-9077-4DDE-8BB1-A025AB0FE75B}',
      '{BF75DC6C-F1A5-4A3C-A6A6-76BCB5DB5881}', '{96B29B2F-888A-4C2B-B8C3-97E9A7849F2F}',
      '{7FDD9158-2E93-4E12-A249-CD9D5445C527}', '{A868CBAC-D9A2-41A7-8A5B-069AB63FEC7B}',
      '{83462AE4-27BB-4B63-9E3E-F435BD03BB12}',
      '{87B4BD93-A5E5-469E-9224-8A289C6B2F10}', '{604CF558-B7E1-4271-8543-75E260080DFA}', # 10.5
      '{9666ABD8-8485-4383-B3DD-4D1598F582A3}', '{58264BBA-5F61-41D9-839A-00B6C2C66A63}',
      '{5988C905-772F-4F62-8339-1796C38674B7}', '{ADD5FF4F-EB57-4460-BD33-D55562AE6FA7}',
      '{3294151B-CA4C-4A89-BBC7-DCE521D8A327}', '{EF65064A-96C8-4EA1-B76D-B9BCC97EF76A}',
      '{6B2FA0A8-6F2C-4359-B7A4-D2F9FD63EE97}', '{ACF59C57-A613-44CC-A927-1D8C2B280516}',
      '{2E5E4CDE-9964-4B40-A1F1-843C62AC789E}', '{2901A5D3-C16D-4993-A306-86261B0430B1}',
      '{AC910B51-6077-4055-B042-D72CA0D23D69}', '{8F36D583-35F0-43F2-8F8F-5B696F87183A}',
      '{37C2CAE2-4A81-4289-B318-93D63C63AA47}', '{CC345B69-1E26-4C56-B640-92BCBADBDF06}',
      '{F0FAE80D-0C51-4D9D-A79B-057396A2456D}', '{5BA355D1-D9B6-4CA0-B1C6-694377084464}',
      '{25118D44-AD2D-423F-85F0-5D730A2691B7}', '{D4855344-CEE0-47A3-BD50-D7E2A674D04E}',
      '{9CD66AA3-F0DA-46CC-A5DD-0BB5B23499AD}',
      '{F53FEE2B-54DD-4A6F-8545-6865F4FBF6DC}', '{475ACDE5-D140-4F10-9006-C804CA93D2EF}', # 10.4.1
      '{0547D7D8-7188-4103-9387-A99FE15215AF}', '{25DFAFFF-07CE-42A2-B157-541D7980A3DA}',
      '{771998A8-A440-4F5F-B55A-0FE2C594208B}', '{C120DC32-DBEA-4CB1-94E4-F50A7EE09F5C}',
      '{3294151B-CA4C-4A89-BBC7-DCE521D8A327}', '{E04FB941-248D-4806-9871-04DB306EEA91}',
      '{66CD667D-440D-4CF1-9ECB-C6C77A7A0520}', '{7938463B-E744-4332-8617-39E91B10FC15}',
      '{C22C2AF5-D58E-4A4D-85DF-E3A38C83F37A}', '{9AF62D15-755B-43DE-878A-DBA23D33B28A}',
      '{D4F22207-C5FA-49B0-9466-9E4D37435882}', '{C8ADE9B2-3BC8-4417-97D0-785BA0CD86D9}',
      '{C85A40C5-00B9-4CDE-9299-397BFD5A2EAF}', '{E0BD73FB-4028-4A5D-9A24-9FA0BD614D4B}',
      '{83CF76EC-F959-46B3-9067-F59B2A846D2F}', '{F7D6BD55-8D07-4A57-8284-ADACE0F567D8}',
      '{C56A0E47-D4E1-4762-9BAF-07A19A154EE6}', '{09AC608B-7CE4-4280-9F4E-F2988A58428D}',
      '{5695B2B6-A25E-4013-B5F8-30686FDDFE0D}',
      '{B83D9E06-B57C-4B26-BF7A-004BE10AB2D5}', '{E2C783F3-6F85-4B49-BFCD-6D6A57A2CFCE}', # 10.4
      '{901578F9-BC82-498D-A008-EC3F53F6C943}', '{E3849BEC-6CAF-463F-8EFA-169116A32554}',
      '{EE889E4F-85C7-4B8A-9DAA-5103C9E14FD6}', '{89D96D88-CC2F-4E9B-84DD-5C976A4741EE}',
      '{0913DB77-F27B-4FDE-9F51-01BB97BBEBB9}', '{99B6A03C-D208-4E2E-B374-BA7972334396}',
      '{A0F3D072-0CD1-43D7-AFDA-8F47B15C217C}', '{0FE26871-21C3-4561-B52E-A8FED5C8E821}',
      '{1D1F3C15-F368-44AF-9728-6CF031D478AF}', '{CE5EC52D-B54D-4381-9F6E-2C08F7721620}',
      '{E71AEC5B-25F0-47E5-B52C-847A1B779E48}', '{5DA1F056-A3F1-46D5-8F2E-74E72F85B51B}',
      '{1EB3D37A-902A-43E2-9EAA-1B43BA10C369}', '{839FFEB7-76B5-4CBB-A05E-E2276FC3421D}',
      '{594E1C33-1C6D-49B4-A83F-2A780193B75F}', '{34330B0C-34CD-4DCF-A68D-FDE7A1834659}',
      '{42A96EC7-7CA9-4F68-B946-E9BF84713605}', '{A1A8DAE4-B6F9-446F-8F6A-487F1E07A434}',
      '{3BF277C6-6A88-4F72-A08C-54F1E45F44E5}'
    ]
  else # node['platform'] == 'linux'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       node['arcgis']['version'],
                                       'WebAdaptor', 'Setup')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']

    case node['arcgis']['version']
    when '10.9.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_1091_180206.tar.gz')
    when '10.9'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_109_177888.tar.gz')
    when '10.8.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_1081_175313.tar.gz')
    when '10.8'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_108_172992.tar.gz')
    when '10.7.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1071_169645.tar.gz')
    when '10.7'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_107_167720.tar.gz')
    when '10.6.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1061_164057.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.6'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_106_161911.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.5.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1051_156442.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.5'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_105_154055.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.4.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1041_152000.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    when '10.4'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_104_149448.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    end

    web_adaptor['install_dir'] = '/'
    web_adaptor['install_subdir'] = "arcgis/webadaptor#{node['arcgis']['version']}"
  end

  web_adaptor['setup_options'] = ''

  # Starting from ArcGIS 10.8.1 Web Adaptor registration supports 'ReindexPortalContent' option.
  web_adaptor['reindex_portal_content'] = true
end
