param(
  [string]$LockFile = 'pubspec.lock',
  [int]$Days = 14
)

# Fails when any hosted package in the lock file was published less than
# $Days days ago. Run from the mobile folder.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$cutoff = (Get-Date).ToUniversalTime().AddDays(-$Days)

$packages = New-Object System.Collections.Generic.List[object]
$name = $null
$source = $null
$version = $null

function Save-Package {
  if ($script:name -and $script:source -eq 'hosted' -and $script:version) {
    $script:packages.Add([pscustomobject]@{
      Name = $script:name
      Version = $script:version
    })
  }
}

foreach ($line in Get-Content $LockFile) {
  if ($line -match '^  ([A-Za-z0-9_]+):\s*$') {
    Save-Package
    $name = $Matches[1]
    $source = $null
    $version = $null
  } elseif ($line -match '^    source:\s*(\w+)') {
    $source = $Matches[1]
  } elseif ($line -match '^    version:\s*"([^"]+)"') {
    $version = $Matches[1]
  }
}
Save-Package

function Get-Published([string]$pkg, [string]$ver) {
  $url = "https://pub.dev/api/packages/$pkg/versions/$ver"
  for ($attempt = 1; $attempt -le 3; $attempt++) {
    try {
      $info = Invoke-RestMethod -Uri $url -TimeoutSec 30
      $raw = $info.published
      if ($raw -is [datetime]) { return $raw.ToUniversalTime() }
      return [datetimeoffset]::Parse(
        $raw,
        [Globalization.CultureInfo]::InvariantCulture
      ).UtcDateTime
    } catch {
      if ($attempt -eq 3) { throw }
      Start-Sleep -Seconds 2
    }
  }
}

$tooNew = New-Object System.Collections.Generic.List[object]
foreach ($p in $packages) {
  $published = Get-Published $p.Name $p.Version
  if ($published -gt $cutoff) {
    $tooNew.Add([pscustomobject]@{
      Package = $p.Name
      Version = $p.Version
      Published = $published.ToString('yyyy-MM-dd HH:mm')
    })
  }
}

"Checked $($packages.Count) hosted packages against a $Days day minimum."
if ($tooNew.Count -gt 0) {
  Write-Host 'Too new:' -ForegroundColor Red
  $tooNew | Format-Table -AutoSize
  exit 1
}
Write-Host 'Every version is old enough.' -ForegroundColor Green