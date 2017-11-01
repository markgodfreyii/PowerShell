<#
Set Lenovo BIOS Settings
For Windows 10 TS
Enable Secure Boot
By Mark Godfrey @Geodesicz
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
