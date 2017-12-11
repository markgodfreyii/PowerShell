<# 
.SYNOPSIS 
Set Boot Order in Lenovo BIOS on ThinkPad
.DESCRIPTION 
Set Boot Order via WMI for Lenovo ThinkPads  - Created by Mark Godfrey @Geodesicz
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

# Set Boot Order
$SetBIOS.SetBiosSetting("BootOrder,HDD0:PCILAN,$BIOSPassword,ascii,us")

# Lock Boot Order
$SetBIOS.SetBiosSetting("BootOrderLock,Enable,$BIOSPassword,ascii,us")

# Save BIOS Settings
$SaveBIOS.SaveBiosSettings("$BIOSPassword,ascii,us")
