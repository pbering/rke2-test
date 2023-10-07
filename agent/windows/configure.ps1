$ProgressPreference = "SilentlyContinue"

# enabled container support
Enable-WindowsOptionalFeature -Online -FeatureName 'Containers' -All -NoRestart

# set PowerShell as default shell for SSH connections
if ($null -eq (Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\OpenSSH' -Name "DefaultShell" -ErrorAction "SilentlyContinue"))
{
    New-ItemProperty -Path 'HKLM:\\SOFTWARE\\OpenSSH' -Name DefaultShell -Value 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' -PropertyType String -Force | Out-Null
}

# disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
