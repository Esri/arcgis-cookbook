#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webadaptor
#
# Copyright 2024-2025 Esri
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

  web_adaptor['admin_access'] = true
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
    when '12.1'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_121_200166.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{3EBF5B44-4B62-4E7D-ADF8-2F1BE4419867}', '{10E702C4-5461-45C2-9BF7-0E4861D4CB15}',
        '{CFEF5F3A-9B91-4124-8863-C724282F3DD1}', '{37E9E565-596E-4C47-8319-A57E404988A0}',
        '{6F91314C-BC9A-4AF9-94B7-1F12FB68BB09}', '{B978AEF5-56CC-4D75-A8A5-72369B307F0C}',
        '{4B83513E-4505-436C-A0ED-6AAAE100CEB6}', '{2A880BAB-A224-4EDC-A575-713C89FFE307}',
        '{7B13AAB0-EA92-43B7-B911-143C020946C0}', '{909A3A6D-E97B-4C18-9E28-4BC670868EB4}',
        '{53ED8318-CBCB-4E58-8BD4-757DF2F72514}', '{2A394041-E353-478A-9C95-427537B383BF}',
        '{53DB779D-9705-4C83-A09B-E047171BC780}', '{F8252420-C71B-476D-B190-E291159087FB}',
        '{C334CDA9-D6E6-4E10-BFD9-D3E69D815F20}', '{E6BE03C5-E4C9-4E4D-B1D1-481FBF0DE00D}',
        '{73C3EA6E-07E6-484C-8B37-9999498F2E6D}', '{3782A1E6-DADF-4629-A8C1-897D0D7C4D2C}',
        '{3CC697B6-50CD-4DB0-A775-91A50E601ABE}', '{51262449-468F-4F31-AE23-58CFA276BCF6}',
        '{18F949CD-2887-482D-BE7F-11E0797AFB1F}', '{D917129E-84D7-4965-8C1C-6647FC3C390D}',
        '{6DC057CC-279C-4B2D-83A2-C6A882D5FC7E}', '{BAF5DFA6-930F-4726-B9F2-41E2D8BDA98F}',
        '{A54A42A1-3DF1-49FC-809B-A3CFB97C563C}', '{08869055-8E45-47D1-BE1A-E0E7EE21D139}',
        '{9A6D4A47-09D6-43E3-A66E-397599052291}', '{88EF3E0B-744A-4D12-AA78-51C97A785B25}',
        '{B8EBCC18-FDD7-454B-A1A2-DC1BA36C1D72}', '{DC686101-411F-424D-BBBA-63ADED7880AE}',
        '{3FFA65CF-5696-4726-9F68-F8CF4B616434}', '{B2E56531-2941-4614-AD12-91F0B2DD07FB}',
        '{181C90B1-BDDD-4DA3-BD45-5D8BC3603D41}', '{95A27070-2B74-4DE6-9A1D-C02FB0AB2D49}',
        '{264541CF-FDAF-410C-9D64-0E745A2CBF30}', '{448D6332-B41F-4A9D-852B-484FFE5875EC}',
        '{B9EC1A0B-E377-4EE5-99F5-2B93E13A6D9F}', '{7060272F-2AEB-4569-9E90-2DAD0D3C520B}',
        '{B2594ED6-2F00-4DB0-932B-D04D422DAF36}', '{71ECBE5D-7995-48DE-833A-2E05535550F8}',
        '{0E70B283-6622-4E05-889C-6952678CBDDE}', '{799C961D-A5FF-4F8F-AABE-27F654D13339}',
        '{5DDEEFB0-0C4C-483D-8AD3-0425981D4B97}', '{4C4C8FA0-1DDA-4E17-8A8E-6B4D3E12BED7}',
        '{DFE77477-1106-4784-91C3-7DA5436CC8B3}', '{A73584A8-8AF4-4C5A-A3B9-4CACCCF0E5ED}',
        '{C58E3698-6DF3-419C-A1D6-0F9A90114805}', '{2E7F4E14-11A2-4963-A24D-949107B404C2}',
        '{5C560E1E-6266-41F8-B76F-B1296A48815F}', '{E664E225-7F7D-4B03-9218-0F64AFD57E95}',
        '{B0E93D95-F062-40F5-8863-0FA4863C0033}', '{852703F7-78E1-4F00-BCC0-FF98D8A39E7B}',
        '{01B6CA84-23DF-47BD-8093-7536AC0C9776}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 12.1\\Updates'

      # ASP.NET Core Runtime 10 Hosting Bundle and Web Deploy 4.0 are required by ArcGIS Web Adaptor IIS 12.1. 
      web_adaptor['dotnet_setup_url'] = 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.1/dotnet-hosting-10.0.1-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-10.0.1-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/webdeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '12.0'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_120_197711.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{BB194DE8-F519-4660-837F-B6AAA3650DEB}', '{2F6059F3-08E0-45D6-B75E-D99A26F46923}',
        '{7C748A51-F096-4886-B7DB-A8F1D09AF36B}', '{A6571CB2-ED32-4406-99DE-1115CC67A159}',
        '{532FC0CE-63C1-4AC0-823E-C11DEBCB014D}', '{135DE6D2-F950-4502-8A3F-207590E63385}',
        '{A7B6D59B-E59C-4799-9793-1E062FE57C4C}', '{4C04F842-BF8B-4789-8FDC-092767AC09A7}',
        '{49530C4D-F9E1-4AB1-9386-0ADA92BBE99B}', '{1FF4D167-C240-48BC-961A-F819EB364283}',
        '{AE371E47-D666-41D7-ABD2-06304FAC2CE1}', '{CC85E3D7-FBEB-417A-B94B-83721721144D}',
        '{319AFA39-5272-4944-A4DA-FACFB484737B}', '{1B923CCF-53C3-49BF-99D0-B8A0D4AFF648}',
        '{B023628D-AC80-425B-A052-BCD26AD5A547}', '{3650EF99-D4A5-4A8F-AA28-09935A66EBFA}',
        '{0033A180-F240-422A-B1A7-9F4FEDD8B20E}', '{FF312ADC-BDEB-4AF7-9B27-CE849400D4CB}',
        '{FF480938-7A92-438E-B634-E46B747FA4AA}', '{D965B597-02B4-4BAD-B7B5-2C8780BEDCAC}',
        '{C259A6BB-BF51-4793-A77B-359B5A9D274E}', '{B0868301-627D-4A6B-A301-5C9FC120418E}',
        '{578A334A-F1D4-4846-B6FE-9B6087FC4DC1}', '{8E07BB12-EC11-4477-AC15-EB93A39AA736}',
        '{25689A35-9378-4A80-B5C9-CB5723732D0F}', '{6F484488-A8EA-4483-9700-EA173C86DE5F}',
        '{F89A57CE-6340-4549-8893-85B86A3315C9}', '{01BB8344-7A5D-4204-B046-B8FC5B1EB1AF}',
        '{C829C6CE-2239-4B9F-97ED-8B93CE13006E}', '{B294CD04-C562-4C42-A3D0-A3F353F58352}',
        '{B0D9C28E-26A2-4362-9FE3-1504BF92C204}', '{C3FE2DBA-83B6-40B4-954E-4733FF7F4C0C}',
        '{07F81319-C8A9-4A73-87FE-6C3FFEEE187A}', '{4CC28D62-8260-4537-9E6D-578432579EA6}',
        '{11517C11-A569-42DF-A109-35ED8A383215}', '{8501FB6A-2543-4857-8C68-F59EB83A5F14}',
        '{09542E0F-0313-4249-9970-7CEB90902D2A}', '{095279E6-82B0-4915-93C1-B0B3F7491BB5}',
        '{B698BDD0-DC3E-41B0-B1D5-566B522EDD4F}', '{DCE0A9CB-20E5-46F7-8A89-DA9DAC1658EF}',
        '{1AF687D6-A15F-4AC1-A5B8-202BEF43AA92}', '{D38DC6CD-7D57-477E-B5B4-CB3A704654C8}',
        '{0CCFF04D-8F0A-45FC-B326-A6A3D2E828B0}', '{BF863CEF-1BE9-40F6-976B-680D502F9C0F}',
        '{9BC57233-80DA-4EAD-96D1-ED07FDCD602B}', '{C68E9488-FD2B-426D-B431-48EACEF2D8CE}',
        '{58EB33C9-5156-406D-81EE-B9B20603FEAA}', '{4D4A68E7-56E0-43E0-94DF-B18CBAB9E205}',
        '{4350A88A-9027-40C1-91CA-0D9235BE4042}', '{1F78C428-AC73-4858-A4D2-FCEB3123F156}',
        '{B2E5F1AB-51EB-492D-BF61-A43002F7F8D2}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 12.0\\Updates'

      # ASP.NET Core Runtime 8 Hosting Bundle and Web Deploy 4.0 are required by ArcGIS Web Adaptor IIS 6. 
      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/4956ec5e-8502-4454-8f28-40239428820f/e7181890eed8dfa11cefbf817c4e86b0/dotnet-hosting-8.0.11-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-8.0.11-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/webdeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '11.5'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_115_195371.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{B87FD5D1-7ED0-424B-8A79-CE4B231CF085}', '{A944DC16-D9B0-4FEC-AAFB-9CC9D5D45414}',
        '{CACEC5F2-E484-40E5-BC3E-D82A19554E40}', '{EC659D96-A962-4F04-AF02-42CDD3CC8C6A}',
        '{7D357A92-E949-4322-95D5-6EB58640C078}', '{4782E831-37C1-4B83-B975-9D0E0F373135}',
        '{CC3694A7-F3EC-4358-9F06-DD1D2EBC4B1D}', '{BD0A6A4E-4B75-48E9-8ABF-9774E7960CAB}',
        '{43E50FE3-F1E4-416C-924D-9604296C2090}', '{276501DB-F08D-4489-BF02-D12430E7BB5C}',
        '{BE613B94-61AF-4B48-A0CA-DDCB134CE9CA}', '{F3D1F822-9CE3-46CE-8ACA-8CFD737F6604}',
        '{155FF541-DB93-49F4-BB01-B5495F707807}', '{5A969923-9741-4FA9-81AB-13B776DFF16E}',
        '{BFBAA84A-008F-493F-B6D3-EC12AD4C57BD}', '{72A84420-32D8-462F-968B-92F25B02D73C}',
        '{F048814A-3140-461F-A399-13F234344AF0}', '{ADD92D5D-540E-4532-AB53-DA19D76FFBE2}',
        '{E594184E-A395-49AB-860F-6EA29C50423F}', '{F2C56B3D-BA68-413F-9916-C2CDCEDD9C7E}',
        '{7ADDF6BE-4277-4814-A31C-DF36D0ADE5E3}', '{362763DC-B9B5-46E8-80AB-17C082646B2A}',
        '{A3B15EFA-172D-40EF-B5B9-382777992697}', '{83C7DEB5-C160-4520-9F45-1B2C1A55B5C0}',
        '{A0B36D8D-9551-4EDA-974E-9ED1CEC5151A}', '{AAD36199-6837-4865-8692-02BA825874B7}',
        '{DD14E295-6798-407E-A5A0-870C8341577E}', '{E25BD1CE-3A98-4833-B021-E5F1FB613F21}',
        '{5118D9DB-543E-45EA-AE06-08A0A67143A1}', '{DCBFF94C-763C-4F36-A10C-2AFD9A335334}',
        '{DD063BF3-0D8E-4E58-B295-C48827E13893}', '{59062D7E-E4E7-4567-9634-4E51F42D6BCA}',
        '{C26ABB80-29AF-4328-834E-A3C0ECF298B4}', '{0654FE83-95A5-481E-B5B2-61A3FEDFA5C4}',
        '{77EE6E4F-5A1D-4DBB-9688-027DA4DF3BAB}', '{2558441D-97F6-419A-9AF9-A0F4D56C1AC4}',
        '{468A6A59-C347-4B59-952F-697390488CE3}', '{003BAC29-91FE-4185-A90B-945F82847E67}',
        '{817458AC-05F3-4A68-AD26-A6E894EAECD5}', '{5C2E1A0C-B17C-4CA0-B230-4934C4AD11CF}',
        '{CE3DAA74-A08E-46B1-B963-8552A486F9C2}', '{2EBA8AD2-0DA0-4143-B878-9FD1303635A3}',
        '{CD758D69-D265-4053-A62F-AF4525F61BD5}', '{709E6312-B1F0-48A6-8347-5186CDF5AD07}',
        '{2CB5A7D6-51DA-4CD1-ADF9-4F7036E8D36B}', '{9A94211B-33E6-4311-9B0D-3CD1BBCEE423}',
        '{73E65AC0-BE55-4BDC-8586-9CC9634C692D}', '{513D8FE8-4999-4D9C-98A4-03F9EBC5B50C}',
        '{777F527D-2D43-4430-8E8F-A93B71FA1C4D}', '{C74184F9-8D73-4F9A-8C47-187F28B9A92A}',
        '{6FA4997E-158E-4A9B-A093-7473A259500E}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 11.5\\Updates'

      # ASP.NET Core Runtime 8 Hosting Bundle and Web Deploy 4.0 are required by ArcGIS Web Adaptor IIS 6. 
      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/4956ec5e-8502-4454-8f28-40239428820f/e7181890eed8dfa11cefbf817c4e86b0/dotnet-hosting-8.0.11-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-8.0.11-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/webdeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
    when '11.4'
      web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                         "ArcGIS #{node['arcgis']['version']}",
                                         'WebAdaptorIIS', 'Setup.exe').gsub('/', '\\')
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_for_Microsoft_IIS_114_192944.exe').gsub('/', '\\')
      web_adaptor['product_codes'] = [
        '{A1EEF9DE-E054-461A-BAB8-EE7FF8C8C6E6}', '{37A3BCC2-9A76-4D87-AC2A-993582ECF891}',
        '{51D04E2F-9196-43DC-950E-173EED1290D4}', '{5C9B7DA6-01DC-425E-BA94-427DDE199959}',
        '{D7BDB359-3BCE-4153-A570-7948C6097FF4}', '{6827D461-6440-4C74-9F83-7D7BF9F57F93}',
        '{47AA6E11-0D24-47C1-99E6-9C0F4B318FFF}', '{BC0F76E2-9583-4E66-8CA6-FD343F329B31}',
        '{A99CDDFA-B1A0-4924-A659-61E4E1BBCB83}', '{B00814E3-1EBC-41AC-A632-8D0494885AE2}',
        '{BECA4DB4-7080-4504-96F9-861884FB3FBA}', '{356E98BB-0E15-4FBD-9AAE-81FC15213B7F}',
        '{51875907-8D8B-46B4-A694-519FDB8F9907}', '{E85450CF-E7A9-4281-9C2A-3CC8CDA952A9}',
        '{703152AA-069F-46AB-9080-404463A073E4}', '{E514597B-CDE7-460D-9FD1-04B9B786DB23}',
        '{0ED2A3FD-4B6B-4006-B10C-9F45F1D90CFC}', '{75A1143F-82EC-42D1-9081-30901CF73614}',
        '{D86A7B19-67FA-4EA3-86EE-A210F618B274}', '{AF997D9E-270C-4CB9-88B5-EFF0FE3F930B}',
        '{718DE748-4F62-4A16-862D-670564FF79ED}', '{9AD6E83D-DC7B-47FD-AC52-3B3DD1FDA07D}',
        '{000B3034-FA23-46E6-A5A5-FD13EB302F5F}', '{C79C1A34-2364-4DCB-BA6B-BA6D22A919D9}',
        '{2479729B-3FFA-41C3-A2C6-4D992782A243}', '{C0FA8EE3-5230-400B-B80E-2F6950D606A4}',
        '{66FD8F46-B3CF-4C1F-9B04-B5894FD41A75}', '{C87ACC53-FC3D-4527-AB2C-D5FBB41A1F34}',
        '{8976EB40-82E0-4583-A255-EEB30EC86161}', '{743EDE64-11F6-46BF-85E7-A64ADE4CA7F0}',
        '{7C841837-FDDE-493E-BCC1-2E8514AFE146}', '{ABFAD895-1F0D-4D50-AFF2-DAD9303FA2A0}',
        '{CBE7BA7E-0A46-4AEF-AC5D-E7A7C7986701}', '{B61D5494-BD5F-4583-9564-AEA33C2DA6E3}',
        '{C190AA6A-46A8-4068-840C-125FA21918BB}', '{C5174467-893B-4D38-ABD9-1FA9CB2FB1AD}',
        '{42C04A4F-7E12-4E37-8143-C8CDBD7E1DE4}', '{22732FD0-C451-4284-B35A-D040B5A16FEC}',
        '{46FA248B-A29F-42CA-AC41-201F675BD9F3}', '{ACD97940-DA22-4761-8962-8E531EE0EC0A}',
        '{98671F19-A3DC-4310-970A-E74C8950E3A5}', '{478AABC4-FCD7-4956-9421-F2AE705245DF}',
        '{E64B3CED-3FFE-4B21-AFD6-CBC400707329}', '{15BAD677-D80E-48A6-84D9-ED1F1C002816}',
        '{C630E05F-7208-447C-86CE-FEF27E2DDE1C}', '{D721DFD5-9DF9-4F8A-BD45-D61E2D719F91}',
        '{FCEF4ECC-D7A8-4192-8E47-7A22221A70D2}', '{57244572-CDD1-4079-B5E7-526CB411109D}',
        '{4A38BCCB-3CBB-47CC-BF03-F4B6178280E6}', '{9608A7E2-D821-4CFF-A8EA-9D9C27A6585C}',
        '{EB8847FE-9A77-4933-8D0E-874F0F7399C2}'
      ]

      web_adaptor['config_web_adaptor_exe'] = ::File.join(ENV['CommonProgramFiles'],
                                                          'ArcGIS\\WebAdaptor\\IIS',
                                                          node['arcgis']['version'],
                                                          'Tools\\ConfigureWebAdaptor.exe').gsub('/', '\\')

      web_adaptor['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Web Adaptor (IIS) 11.4\\Updates'

      # ASP.NET Core Runtime 8 Hosting Bundle and Web Deploy 4.0 are required by ArcGIS Web Adaptor IIS 6. 
      web_adaptor['dotnet_setup_url'] = 'https://download.visualstudio.microsoft.com/download/pr/751d3fcd-72db-4da2-b8d0-709c19442225/33cc492bde704bfd6d70a2b9109005a0/dotnet-hosting-8.0.6-win.exe'
      web_adaptor['dotnet_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'dotnet-hosting-8.0.6-win.exe').gsub('/', '\\')

      web_adaptor['web_deploy_setup_url'] = 'https://download.microsoft.com/download/webdeploy_amd64_en-US.msi'
      web_adaptor['web_deploy_setup_path'] = ::File.join(node['arcgis']['repository']['setups'], 'WebDeploy_amd64_en-US.msi').gsub('/', '\\')
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
      '{3EBF5B44-4B62-4E7D-ADF8-2F1BE4419867}', '{10E702C4-5461-45C2-9BF7-0E4861D4CB15}', #12.1
      '{CFEF5F3A-9B91-4124-8863-C724282F3DD1}', '{37E9E565-596E-4C47-8319-A57E404988A0}',
      '{6F91314C-BC9A-4AF9-94B7-1F12FB68BB09}', '{B978AEF5-56CC-4D75-A8A5-72369B307F0C}',
      '{4B83513E-4505-436C-A0ED-6AAAE100CEB6}', '{2A880BAB-A224-4EDC-A575-713C89FFE307}',
      '{7B13AAB0-EA92-43B7-B911-143C020946C0}', '{909A3A6D-E97B-4C18-9E28-4BC670868EB4}',
      '{53ED8318-CBCB-4E58-8BD4-757DF2F72514}', '{2A394041-E353-478A-9C95-427537B383BF}',
      '{53DB779D-9705-4C83-A09B-E047171BC780}', '{F8252420-C71B-476D-B190-E291159087FB}',
      '{C334CDA9-D6E6-4E10-BFD9-D3E69D815F20}', '{E6BE03C5-E4C9-4E4D-B1D1-481FBF0DE00D}',
      '{73C3EA6E-07E6-484C-8B37-9999498F2E6D}', '{3782A1E6-DADF-4629-A8C1-897D0D7C4D2C}',
      '{3CC697B6-50CD-4DB0-A775-91A50E601ABE}', '{51262449-468F-4F31-AE23-58CFA276BCF6}',
      '{18F949CD-2887-482D-BE7F-11E0797AFB1F}', '{D917129E-84D7-4965-8C1C-6647FC3C390D}',
      '{6DC057CC-279C-4B2D-83A2-C6A882D5FC7E}', '{BAF5DFA6-930F-4726-B9F2-41E2D8BDA98F}',
      '{A54A42A1-3DF1-49FC-809B-A3CFB97C563C}', '{08869055-8E45-47D1-BE1A-E0E7EE21D139}',
      '{9A6D4A47-09D6-43E3-A66E-397599052291}', '{88EF3E0B-744A-4D12-AA78-51C97A785B25}',
      '{B8EBCC18-FDD7-454B-A1A2-DC1BA36C1D72}', '{DC686101-411F-424D-BBBA-63ADED7880AE}',
      '{3FFA65CF-5696-4726-9F68-F8CF4B616434}', '{B2E56531-2941-4614-AD12-91F0B2DD07FB}',
      '{181C90B1-BDDD-4DA3-BD45-5D8BC3603D41}', '{95A27070-2B74-4DE6-9A1D-C02FB0AB2D49}',
      '{264541CF-FDAF-410C-9D64-0E745A2CBF30}', '{448D6332-B41F-4A9D-852B-484FFE5875EC}',
      '{B9EC1A0B-E377-4EE5-99F5-2B93E13A6D9F}', '{7060272F-2AEB-4569-9E90-2DAD0D3C520B}',
      '{B2594ED6-2F00-4DB0-932B-D04D422DAF36}', '{71ECBE5D-7995-48DE-833A-2E05535550F8}',
      '{0E70B283-6622-4E05-889C-6952678CBDDE}', '{799C961D-A5FF-4F8F-AABE-27F654D13339}',
      '{5DDEEFB0-0C4C-483D-8AD3-0425981D4B97}', '{4C4C8FA0-1DDA-4E17-8A8E-6B4D3E12BED7}',
      '{DFE77477-1106-4784-91C3-7DA5436CC8B3}', '{A73584A8-8AF4-4C5A-A3B9-4CACCCF0E5ED}',
      '{C58E3698-6DF3-419C-A1D6-0F9A90114805}', '{2E7F4E14-11A2-4963-A24D-949107B404C2}',
      '{5C560E1E-6266-41F8-B76F-B1296A48815F}', '{E664E225-7F7D-4B03-9218-0F64AFD57E95}',
      '{B0E93D95-F062-40F5-8863-0FA4863C0033}', '{852703F7-78E1-4F00-BCC0-FF98D8A39E7B}',
      '{01B6CA84-23DF-47BD-8093-7536AC0C9776}',
      '{BB194DE8-F519-4660-837F-B6AAA3650DEB}', '{2F6059F3-08E0-45D6-B75E-D99A26F46923}', # 12.0
      '{7C748A51-F096-4886-B7DB-A8F1D09AF36B}', '{A6571CB2-ED32-4406-99DE-1115CC67A159}',
      '{532FC0CE-63C1-4AC0-823E-C11DEBCB014D}', '{135DE6D2-F950-4502-8A3F-207590E63385}',
      '{A7B6D59B-E59C-4799-9793-1E062FE57C4C}', '{4C04F842-BF8B-4789-8FDC-092767AC09A7}',
      '{49530C4D-F9E1-4AB1-9386-0ADA92BBE99B}', '{1FF4D167-C240-48BC-961A-F819EB364283}',
      '{AE371E47-D666-41D7-ABD2-06304FAC2CE1}', '{CC85E3D7-FBEB-417A-B94B-83721721144D}',
      '{319AFA39-5272-4944-A4DA-FACFB484737B}', '{1B923CCF-53C3-49BF-99D0-B8A0D4AFF648}',
      '{B023628D-AC80-425B-A052-BCD26AD5A547}', '{3650EF99-D4A5-4A8F-AA28-09935A66EBFA}',
      '{0033A180-F240-422A-B1A7-9F4FEDD8B20E}', '{FF312ADC-BDEB-4AF7-9B27-CE849400D4CB}',
      '{FF480938-7A92-438E-B634-E46B747FA4AA}', '{D965B597-02B4-4BAD-B7B5-2C8780BEDCAC}',
      '{C259A6BB-BF51-4793-A77B-359B5A9D274E}', '{B0868301-627D-4A6B-A301-5C9FC120418E}',
      '{578A334A-F1D4-4846-B6FE-9B6087FC4DC1}', '{8E07BB12-EC11-4477-AC15-EB93A39AA736}',
      '{25689A35-9378-4A80-B5C9-CB5723732D0F}', '{6F484488-A8EA-4483-9700-EA173C86DE5F}',
      '{F89A57CE-6340-4549-8893-85B86A3315C9}', '{01BB8344-7A5D-4204-B046-B8FC5B1EB1AF}',
      '{C829C6CE-2239-4B9F-97ED-8B93CE13006E}', '{B294CD04-C562-4C42-A3D0-A3F353F58352}',
      '{B0D9C28E-26A2-4362-9FE3-1504BF92C204}', '{C3FE2DBA-83B6-40B4-954E-4733FF7F4C0C}',
      '{07F81319-C8A9-4A73-87FE-6C3FFEEE187A}', '{4CC28D62-8260-4537-9E6D-578432579EA6}',
      '{11517C11-A569-42DF-A109-35ED8A383215}', '{8501FB6A-2543-4857-8C68-F59EB83A5F14}',
      '{09542E0F-0313-4249-9970-7CEB90902D2A}', '{095279E6-82B0-4915-93C1-B0B3F7491BB5}',
      '{B698BDD0-DC3E-41B0-B1D5-566B522EDD4F}', '{DCE0A9CB-20E5-46F7-8A89-DA9DAC1658EF}',
      '{1AF687D6-A15F-4AC1-A5B8-202BEF43AA92}', '{D38DC6CD-7D57-477E-B5B4-CB3A704654C8}',
      '{0CCFF04D-8F0A-45FC-B326-A6A3D2E828B0}', '{BF863CEF-1BE9-40F6-976B-680D502F9C0F}',
      '{9BC57233-80DA-4EAD-96D1-ED07FDCD602B}', '{C68E9488-FD2B-426D-B431-48EACEF2D8CE}',
      '{58EB33C9-5156-406D-81EE-B9B20603FEAA}', '{4D4A68E7-56E0-43E0-94DF-B18CBAB9E205}',
      '{4350A88A-9027-40C1-91CA-0D9235BE4042}', '{1F78C428-AC73-4858-A4D2-FCEB3123F156}',
      '{B2E5F1AB-51EB-492D-BF61-A43002F7F8D2}',
      '{B87FD5D1-7ED0-424B-8A79-CE4B231CF085}', '{A944DC16-D9B0-4FEC-AAFB-9CC9D5D45414}', # 11.5
      '{CACEC5F2-E484-40E5-BC3E-D82A19554E40}', '{EC659D96-A962-4F04-AF02-42CDD3CC8C6A}',
      '{7D357A92-E949-4322-95D5-6EB58640C078}', '{4782E831-37C1-4B83-B975-9D0E0F373135}',
      '{CC3694A7-F3EC-4358-9F06-DD1D2EBC4B1D}', '{BD0A6A4E-4B75-48E9-8ABF-9774E7960CAB}',
      '{43E50FE3-F1E4-416C-924D-9604296C2090}', '{276501DB-F08D-4489-BF02-D12430E7BB5C}',
      '{BE613B94-61AF-4B48-A0CA-DDCB134CE9CA}', '{F3D1F822-9CE3-46CE-8ACA-8CFD737F6604}',
      '{155FF541-DB93-49F4-BB01-B5495F707807}', '{5A969923-9741-4FA9-81AB-13B776DFF16E}',
      '{BFBAA84A-008F-493F-B6D3-EC12AD4C57BD}', '{72A84420-32D8-462F-968B-92F25B02D73C}',
      '{F048814A-3140-461F-A399-13F234344AF0}', '{ADD92D5D-540E-4532-AB53-DA19D76FFBE2}',
      '{E594184E-A395-49AB-860F-6EA29C50423F}', '{F2C56B3D-BA68-413F-9916-C2CDCEDD9C7E}',
      '{7ADDF6BE-4277-4814-A31C-DF36D0ADE5E3}', '{362763DC-B9B5-46E8-80AB-17C082646B2A}',
      '{A3B15EFA-172D-40EF-B5B9-382777992697}', '{83C7DEB5-C160-4520-9F45-1B2C1A55B5C0}',
      '{A0B36D8D-9551-4EDA-974E-9ED1CEC5151A}', '{AAD36199-6837-4865-8692-02BA825874B7}',
      '{DD14E295-6798-407E-A5A0-870C8341577E}', '{E25BD1CE-3A98-4833-B021-E5F1FB613F21}',
      '{5118D9DB-543E-45EA-AE06-08A0A67143A1}', '{DCBFF94C-763C-4F36-A10C-2AFD9A335334}',
      '{DD063BF3-0D8E-4E58-B295-C48827E13893}', '{59062D7E-E4E7-4567-9634-4E51F42D6BCA}',
      '{C26ABB80-29AF-4328-834E-A3C0ECF298B4}', '{0654FE83-95A5-481E-B5B2-61A3FEDFA5C4}',
      '{77EE6E4F-5A1D-4DBB-9688-027DA4DF3BAB}', '{2558441D-97F6-419A-9AF9-A0F4D56C1AC4}',
      '{468A6A59-C347-4B59-952F-697390488CE3}', '{003BAC29-91FE-4185-A90B-945F82847E67}',
      '{817458AC-05F3-4A68-AD26-A6E894EAECD5}', '{5C2E1A0C-B17C-4CA0-B230-4934C4AD11CF}',
      '{CE3DAA74-A08E-46B1-B963-8552A486F9C2}', '{2EBA8AD2-0DA0-4143-B878-9FD1303635A3}',
      '{CD758D69-D265-4053-A62F-AF4525F61BD5}', '{709E6312-B1F0-48A6-8347-5186CDF5AD07}',
      '{2CB5A7D6-51DA-4CD1-ADF9-4F7036E8D36B}', '{9A94211B-33E6-4311-9B0D-3CD1BBCEE423}',
      '{73E65AC0-BE55-4BDC-8586-9CC9634C692D}', '{513D8FE8-4999-4D9C-98A4-03F9EBC5B50C}',
      '{777F527D-2D43-4430-8E8F-A93B71FA1C4D}', '{C74184F9-8D73-4F9A-8C47-187F28B9A92A}',
      '{6FA4997E-158E-4A9B-A093-7473A259500E}',
      '{A1EEF9DE-E054-461A-BAB8-EE7FF8C8C6E6}', '{37A3BCC2-9A76-4D87-AC2A-993582ECF891}', # 11.4
      '{51D04E2F-9196-43DC-950E-173EED1290D4}', '{5C9B7DA6-01DC-425E-BA94-427DDE199959}',
      '{D7BDB359-3BCE-4153-A570-7948C6097FF4}', '{6827D461-6440-4C74-9F83-7D7BF9F57F93}',
      '{47AA6E11-0D24-47C1-99E6-9C0F4B318FFF}', '{BC0F76E2-9583-4E66-8CA6-FD343F329B31}',
      '{A99CDDFA-B1A0-4924-A659-61E4E1BBCB83}', '{B00814E3-1EBC-41AC-A632-8D0494885AE2}',
      '{BECA4DB4-7080-4504-96F9-861884FB3FBA}', '{356E98BB-0E15-4FBD-9AAE-81FC15213B7F}',
      '{51875907-8D8B-46B4-A694-519FDB8F9907}', '{E85450CF-E7A9-4281-9C2A-3CC8CDA952A9}',
      '{703152AA-069F-46AB-9080-404463A073E4}', '{E514597B-CDE7-460D-9FD1-04B9B786DB23}',
      '{0ED2A3FD-4B6B-4006-B10C-9F45F1D90CFC}', '{75A1143F-82EC-42D1-9081-30901CF73614}',
      '{D86A7B19-67FA-4EA3-86EE-A210F618B274}', '{AF997D9E-270C-4CB9-88B5-EFF0FE3F930B}',
      '{718DE748-4F62-4A16-862D-670564FF79ED}', '{9AD6E83D-DC7B-47FD-AC52-3B3DD1FDA07D}',
      '{000B3034-FA23-46E6-A5A5-FD13EB302F5F}', '{C79C1A34-2364-4DCB-BA6B-BA6D22A919D9}',
      '{2479729B-3FFA-41C3-A2C6-4D992782A243}', '{C0FA8EE3-5230-400B-B80E-2F6950D606A4}',
      '{66FD8F46-B3CF-4C1F-9B04-B5894FD41A75}', '{C87ACC53-FC3D-4527-AB2C-D5FBB41A1F34}',
      '{8976EB40-82E0-4583-A255-EEB30EC86161}', '{743EDE64-11F6-46BF-85E7-A64ADE4CA7F0}',
      '{7C841837-FDDE-493E-BCC1-2E8514AFE146}', '{ABFAD895-1F0D-4D50-AFF2-DAD9303FA2A0}',
      '{CBE7BA7E-0A46-4AEF-AC5D-E7A7C7986701}', '{B61D5494-BD5F-4583-9564-AEA33C2DA6E3}',
      '{C190AA6A-46A8-4068-840C-125FA21918BB}', '{C5174467-893B-4D38-ABD9-1FA9CB2FB1AD}',
      '{42C04A4F-7E12-4E37-8143-C8CDBD7E1DE4}', '{22732FD0-C451-4284-B35A-D040B5A16FEC}',
      '{46FA248B-A29F-42CA-AC41-201F675BD9F3}', '{ACD97940-DA22-4761-8962-8E531EE0EC0A}',
      '{98671F19-A3DC-4310-970A-E74C8950E3A5}', '{478AABC4-FCD7-4956-9421-F2AE705245DF}',
      '{E64B3CED-3FFE-4B21-AFD6-CBC400707329}', '{15BAD677-D80E-48A6-84D9-ED1F1C002816}',
      '{C630E05F-7208-447C-86CE-FEF27E2DDE1C}', '{D721DFD5-9DF9-4F8A-BD45-D61E2D719F91}',
      '{FCEF4ECC-D7A8-4192-8E47-7A22221A70D2}', '{57244572-CDD1-4079-B5E7-526CB411109D}',
      '{4A38BCCB-3CBB-47CC-BF03-F4B6178280E6}', '{9608A7E2-D821-4CFF-A8EA-9D9C27A6585C}',
      '{EB8847FE-9A77-4933-8D0E-874F0F7399C2}',
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
    web_adaptor['war_file'] = 'arcgis.war'

    case node['arcgis']['version']
    when '12.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_121_200209.tar.gz')                                                
    when '12.0'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_120_197824.tar.gz')                                                
    when '11.5'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_115_195462.tar.gz')
    when '11.4'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'ArcGIS_Web_Adaptor_Java_Linux_114_192983.tar.gz')
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
