<# 
.SYNOPSIS 
Set Other Security Settings in Lenovo BIOS on ThinkPad
.DESCRIPTION 
Set Other Security Settings via WMI for Lenovo ThinkPads  - Created by Mark Godfrey @Geodesicz
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

# Password Count Exceeded Error
$SetBIOS.SetBiosSetting("PasswordCountExceededError,Enable,$BIOSPassword,ascii,us")

# BIOS Password at Boot Device List
$SetBIOS.SetBiosSetting("BIOSPasswordAtBootDeviceList,Enable,$BIOSPassword,ascii,us")

# Secure Rollback Prevention
$SetBIOS.SetBiosSetting("SecureRollBackPrevention,Enable,$BIOSPassword,ascii,us")

# Save BIOS Settings
$SaveBIOS.SaveBiosSettings("$BIOSPassword,ascii,us")
