#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webadaptor
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

default['arcgis']['web_adaptor'].tap do |web_adaptor|

  web_adaptor['admin_access'] = false
  web_adaptor['install_system_requirements'] = true
  web_adaptor['setup_archive'] = ''
  web_adaptor['product_codes'] = []
  web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe' 
  
  web_adaptor['patches'] = []

  case node['platform']
  when 'windows'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       "ArcGIS #{node['arcgis']['version']}",
                                       'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']
    web_adaptor['install_dir'] = ''

    case node['arcgis']['version']
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
      web_adaptor['config_web_adaptor_exe'] = '\\ArcGIS\\WebAdaptor\\IIS\\11.0\\Tools\\ConfigureWebAdaptor.exe' 
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 11.0\Updates'
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
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 10.9.1\Updates'
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
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 10.9\Updates'
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
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 10.8.1\Updates'
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
      web_adaptor['patch_registry'] ='SOFTWARE\\WOW6432Node\\ESRI\\ArcGIS Web Adaptor (IIS) 10.8\Updates'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Adaptor version'
    end

    # Product codes used to uninstall ArcGIS Web Adaptor during upgrades.
    # The list includes the first two-four product codes form each supported ArcGIS version.
    web_adaptor['all_product_codes'] = [
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
      '{9452D085-0F4F-4869-B8B4-D660B4DD8692}'
    ]
  else # node['platform'] == 'linux'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       node['arcgis']['version'],
                                       'WebAdaptor', 'Setup')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']

    case node['arcgis']['version']
    when '11.0'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_110_182987.tar.gz')
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
  end

  web_adaptor['setup_options'] = ''

  # Starting from ArcGIS 10.8.1 Web Adaptor registration supports 'ReindexPortalContent' option.
  web_adaptor['reindex_portal_content'] = true
end
