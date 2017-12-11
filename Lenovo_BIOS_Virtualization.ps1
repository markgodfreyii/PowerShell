<# 
.SYNOPSIS 
Enable Virtualization in Lenovo BIOS on ThinkPad
.DESCRIPTION 
Enable Virtualization via WMI for Lenovo ThinkPads  - Created by Mark Godfrey @Geodesicz
.LINK
http://www.tekuits.com 
#> 

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="BIOSPass")]
    [ValidateNotNullOrEmpty()]
    [string]$BIOSPassword
)

# Get Settings
$settings = Get-WmiObject -Namespace root/wmi -Class Lenovo_BiosSetting

# Create Set Object
$SetBIOS = Get-WmiObject -Namespace root/wmi -Class lenovo_setbiossetting

# Create Save Object
$SaveBIOS = Get-WmiObject -Namespace root/wmi -Class lenovo_savebiossettings

# Set Virtualization Settings
$SetBIOS.SetBiosSetting("VirtualizationTechnology,Enable,$BIOSPassword,ascii,us")
$SetBIOS.SetBiosSetting("VtdFeature,Enable,$BIOSPassword,ascii,us")

# Save BIOS Settings
$SaveBIOS.SaveBiosSettings("$BIOSPassword,ascii,us")
