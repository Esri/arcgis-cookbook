param(
  # Name of the Pro JSON file under templates\arcgis-pro\3.5\windows
  [string]$ProJsonName = 'arcgis-pro-install.json'
)

$chefBase         = 'C:\chef'
$chefCache        = 'C:\chef\cache'
$chefDownloadRoot = 'C:\Users'
$esriZipName      = 'arcgis-5.2.0-cookbooks.zip'
$customZipPattern = 'arcgis-cookbook*.zip'

if ($ProJsonName.ToLower().EndsWith('.json')) {
  $proBaseName = [System.IO.Path]::GetFileNameWithoutExtension($ProJsonName)
} else {
  $proBaseName = $ProJsonName
  $ProJsonName = "$ProJsonName.json"
}

$templateJsonSourceRel = "templates\arcgis-pro\3.5\windows\$ProJsonName"
$templateJsonTarget    = "C:\chef\$ProJsonName"
$proTranscript         = "C:\chef\configure-${proBaseName}.transcript.txt"
$proConfigMarker       = "C:\chef\arcgis_pro_35_configured.ok"

try {
  Start-Transcript -Path $proTranscript -Append -ErrorAction SilentlyContinue | Out-Null
} catch {}

Write-Host "=== Preparing C:\chef workspace for ArcGIS Pro 3.5 installation ==="

if (Test-Path $proConfigMarker) {
  Write-Host "Pro configuration marker found; skipping installation."
  try { Stop-Transcript | Out-Null } catch {}
  exit 0
}

New-Item -ItemType Directory -Path $chefBase, $chefCache -Force | Out-Null

$clientRbPath = Join-Path $chefBase 'client.rb'
if (-not (Test-Path $clientRbPath)) {
  $clientRbLines = @(
    'local_mode true',
    'cache_path "C:/chef/cache"',
    'file_cache_path "C:/chef/cache"',
    'log_location "C:/chef/client.log"'
  )
  $clientRbLines -join "`r`n" | Out-File -FilePath $clientRbPath -Encoding ASCII -Force
  Write-Host "Wrote C:\chef\client.rb"
}

$cookbooksDir = Join-Path $chefBase 'cookbooks'
$templatesDir = Join-Path $chefBase 'templates'
$customRoot   = Join-Path $chefBase 'custom-cookbook'

if ((-not (Test-Path $cookbooksDir -PathType Container)) -or (-not (Test-Path $templatesDir -PathType Container))) {
  Write-Host "=== Extracting Esri arcgis-5.2.0-cookbooks.zip for Pro installation ==="

  $esriZip = Get-ChildItem -Path $chefDownloadRoot -Filter $esriZipName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $esriZip) {
    Write-Host "Esri cookbooks zip ($esriZipName) not found under $chefDownloadRoot. Aborting Pro installation."
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
  }

  Expand-Archive -Path $esriZip.FullName -DestinationPath $chefBase -Force

  if (-not (Test-Path $cookbooksDir)) {
    $rootWithCookbooks = Get-ChildItem -Path $chefBase -Directory -ErrorAction SilentlyContinue |
      Where-Object { Test-Path (Join-Path $_.FullName 'cookbooks') } |
      Select-Object -First 1

    if ($rootWithCookbooks) {
      $sourceCookbooks = Join-Path $rootWithCookbooks.FullName 'cookbooks'
      Move-Item -Path $sourceCookbooks -Destination $cookbooksDir -Force

      $sourceTemplates = Join-Path $rootWithCookbooks.FullName 'templates'
      if (Test-Path $sourceTemplates) {
        Move-Item -Path $sourceTemplates -Destination $templatesDir -Force
      }
    }
  }
}

if (-not (Test-Path $templatesDir)) {
  Write-Host "C:\chef\templates not found after extraction. Aborting Pro installation."
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}

Write-Host "=== Overlaying custom $ProJsonName from arcgis-cookbook zip (if present) ==="

$customZip = Get-ChildItem -Path $chefDownloadRoot -Filter $customZipPattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($customZip) {
  if (Test-Path $customRoot) {
    Remove-Item -Path $customRoot -Recurse -Force
  }
  New-Item -ItemType Directory -Path $customRoot -Force | Out-Null

  Expand-Archive -Path $customZip.FullName -DestinationPath $customRoot -Force
  Write-Host ("Expanded custom cookbook zip from {0} to {1}" -f $customZip.FullName, $customRoot)
} else {
  Write-Error "No custom arcgis-cookbook*.zip found under $chefDownloadRoot. Failing execution."
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}

Write-Host "=== Preparing required custom $ProJsonName ==="

$customJsonSource = Join-Path $customRoot ("templates\arcgis-pro\3.5\windows\$ProJsonName")
if (-not (Test-Path $customJsonSource)) {
  Write-Host "Expected path '$customJsonSource' not found; searching recursively for '$ProJsonName' within $customRoot..."
  $found = Get-ChildItem -Path $customRoot -Filter $ProJsonName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($found) {
    $customJsonSource = $found.FullName
  }
}

if (Test-Path $customJsonSource) {
  Copy-Item -Path $customJsonSource -Destination $templateJsonTarget -Force
  Write-Host "Copied required custom Pro template from $customJsonSource to $templateJsonTarget"
} else {
  Write-Error "Required custom Pro template '$ProJsonName' not found at $customJsonSource. Failing execution."
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}

Write-Host "=== Ensuring ArcGIS Pro setup archive is in C:\Software\Archives ==="

$archivesDir = 'C:\Software\Archives'
New-Item -ItemType Directory -Path $archivesDir -Force | Out-Null

$proDownloadRoot = Join-Path $chefDownloadRoot 'arcgis-pro'
$proArchive = $null

if (Test-Path $proDownloadRoot) {
  $proArchive = Get-ChildItem -Path $proDownloadRoot -Filter 'ArcGISPro_35_*.exe' -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object -First 1

  if (-not $proArchive) {
    $proArchive = Get-ChildItem -Path $proDownloadRoot -Filter 'ArcGISPro*.exe' -Recurse -File -ErrorAction SilentlyContinue |
      Select-Object -First 1
  }
}

if (-not $proArchive) {
  Write-Error "ArcGIS Pro setup archive was not found under $proDownloadRoot. Failing execution."
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}

$targetArchive = Join-Path $archivesDir $proArchive.Name
Copy-Item -Path $proArchive.FullName -Destination $targetArchive -Force
Write-Host "Copied ArcGIS Pro archive to $targetArchive"

Write-Host "=== Running Cinc to install ArcGIS Pro 3.5 ==="

$cincClientCandidates = @(
  'C:\cinc-project\cinc\bin\cinc-client.bat',
  'C:\opscode\cinc\bin\cinc-client.bat',
  'C:\opscode\cinc\bin\cinc-client.exe',
  "$env:ProgramFiles\cinc-project\cinc\bin\cinc-client.bat",
  "$env:ProgramFiles\cinc-project\cinc\bin\cinc-client.exe"
)

$clientExePath = $cincClientCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $clientExePath) {
  Write-Host 'cinc-client not found in common install locations; ensure Cinc is installed and retry.'
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}

Push-Location $chefBase

Write-Host "Running Cinc client with template: $templateJsonTarget"
& $clientExePath -z -r "run_list" -j $templateJsonTarget

$cincExitCode = $LASTEXITCODE

Pop-Location

if ($cincExitCode -eq 0) {
  Write-Host "ArcGIS Pro 3.5 installation completed successfully"
  New-Item -Path $proConfigMarker -Force | Out-Null
  Write-Host "Configuration marker created at $proConfigMarker"
} else {
  Write-Error "Cinc execution failed with exit code $cincExitCode"
}

try { Stop-Transcript | Out-Null } catch {}

exit $cincExitCode
