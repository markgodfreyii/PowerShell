<#
Create new local admin account with randomly generated password
Created by Mark Godfrey @Geodesicz
Requires PowerShell 5.1 or newer with Microsoft.PowerShell.LocalAccounts module
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Username")]
    [ValidateNotNullOrEmpty()]
    [string]$Username
)

$User = New-LocalUser -AccountNeverExpires -Name $Username -Password (ConvertTo-SecureString (-join ((33..126) | Get-Random -Count 16 | foreach {[char]$PSItem})) -AsPlainText -Force)
Add-LocalGroupMember -Group "Administrators" -Member $User