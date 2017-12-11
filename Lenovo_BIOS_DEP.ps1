<# 
.SYNOPSIS 
Enable Data Execution Prevention in Lenovo BIOS on ThinkPad
.DESCRIPTION 
Enable Data Execution Prevention via WMI for Lenovo ThinkPads  - Created by Mark Godfrey @Geodesicz
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

# Data Execution Prevention
$SetBIOS.SetBiosSetting("DataExecutionPrevention,Enable,$BIOSPassword,ascii,us")

# Save BIOS Settings
$SaveBIOS.SaveBiosSettings("$BIOSPassword,ascii,us")
