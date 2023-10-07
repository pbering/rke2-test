param(
  [Parameter(Mandatory = $true)]
  [string]$rke2Version
  ,
  [Parameter(Mandatory = $true)]
  [string]$rke2Token
  ,
  [Parameter(Mandatory = $true)]
  [string]$rke2ServerUrl
)

$ProgressPreference = "SilentlyContinue"

# install rke2 agent
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rancher/rke2/master/install.ps1 -OutFile ./install.ps1
New-Item -Type Directory C:/etc/rancher/rke2 -Force | Out-Null
Set-Content -Path C:/etc/rancher/rke2/config.yaml -Value @"
server: $rke2ServerUrl
token: $rke2Token
node-taint:
  - "os=windows:NoSchedule"
"@

$rke2Path = 'c:\var\lib\rancher\rke2\bin;c:\usr\local\bin'
$env:PATH += ";$rke2Path"
[Environment]::SetEnvironmentVariable("PATH", [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";$rke2Path", "Machine")

./install.ps1 -Version $rke2Version

rke2.exe agent service --add

Start-Service rke2