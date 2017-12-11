<# 
.SYNOPSIS 
Enable Secure Boot in Lenovo BIOS on ThinkPad
.DESCRIPTION 
Enable Secure Boot via WMI for Lenovo ThinkPads  - Created by Mark Godfrey @Geodesicz
.LINK
http://www.tekuits.com 
#> 

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$true,Position=1,HelpMessage="BIOS Password")]
    [ValidateNotNullOrEmpty()]
    [string]$BIOSPass

)

# Get Settings
$settings = Get-WmiObject -Namespace root/wmi -Class Lenovo_BiosSetting

# Create Set Object
$SetBIOS = Get-WmiObject -Namespace root/wmi -Class lenovo_setbiossetting

# Create Save Object
$SaveBIOS = Get-WmiObject -Namespace root/wmi -Class lenovo_savebiossettings

# Secure Boot
$SetBIOS.SetBiosSetting("SecureBoot,Enable,$BIOSPass,ascii,us")

# Save BIOS Settings
$SaveBIOS.SaveBiosSettings("$BIOSPass,ascii,us")
