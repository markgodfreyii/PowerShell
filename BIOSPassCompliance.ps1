<#
Validate BIOS Password and Write Compliance to WMI
Created by Mark Godfrey @Geodesicz
Requires MFG-Specific Utilities Within Script Execution Directory
Version 1.1 - 2016.11.02
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="Dell BIOS Password")]
    [ValidateNotNullOrEmpty()]
    [string]$DellBIOSpass,
    [Parameter(HelpMessage="HP BIOS Password bin file")]
    [ValidateNotNullOrEmpty()]
    [string]$HPBiosPassFilename
)

# Dell
If(Get-WmiObject -Query "select * from win32_computersystem where Manufacturer like 'Dell%'"){
    
    # Specify Model
    $Model = "Dell " + ((Get-WmiObject win32_computersystem).model)

    # Validate CCTK Exists
    $CCTKExist = Test-Path "$PSScriptRoot\cctk.exe"

    # CCTK Missing, Throw Error
    If($CCTKExist -eq $false){Write-Error "CCTK utility not found. Place the CCTK utility within the script root folder."}

    # CCTK Exists, Set Value to Write to WMI
    else{
        Set-Location $PSScriptRoot
        $test = .\cctk.exe --setuppwd $DellBIOSpass --valsetuppwd=$DellBIOSpass
        If($test -eq 'The setup password supplied is incorrect. Please try again.'){$Compliance = $False}
        If($test -eq 'Password is changed successfully.'){$Compliance = $True}
    }
}

# HP
If(Get-WmiObject -Query "select * from win32_computersystem where Manufacturer = 'Hewlett-Packard'"){

    # Specify Model
    $Model = (Get-WmiObject win32_computersystem).Model

    # Validate BiosConfigUtility Exists
    $BCUExist = Test-Path "$PSScriptRoot\BiosConfigUtility64.exe"

    # BiosConfigUtility Missing, Throw Error
    If($BCUExist -eq $false){Write-Error "Bios Config Utility not found. Place the Bios Config Utility within the script root folder."}

    # BiosConfigUtility Exists, Set Value to Write to WMI
    else{
        Set-Location $PSScriptRoot
        [xml]$test = .\BiosConfigUtility64.exe /cspwdfile:$HPBiosPassFilename /nspwdfile:$HPBiosPassFilename
        If($test.biosconfig.success -ne $null){$Compliance = $true}else{$Compliance = $false}
    }
}

# Unsupported Manufacturer
If(!(Get-WmiObject -Query "select * from win32_computersystem where Manufacturer like 'Dell%'") -and !(Get-WmiObject -Query "select * from win32_computersystem where Manufacturer = 'Hewlett-Packard'")){Write-Error "Unsupported Device Manufacturer"; exit}

# Set Vars for WMI Info
$Namespace = 'ITLocal'
$Class = 'BIOS_PW_Compliance'

# Does Namespace Already Exist?
Write-Verbose "Getting WMI namespace $Namespace"
$NSfilter = "Name = '$Namespace'"
$NSExist = Get-WmiObject -Namespace root -Class __namespace -Filter $NSfilter
# Namespace Does Not Exist
If($NSExist -eq $null){
    Write-Verbose "$Namespace namespace does not exist. Creating new namespace . . ."
    # Create Namespace
   	$rootNamespace = [wmiclass]'root:__namespace'
    $NewNamespace = $rootNamespace.CreateInstance()
	$NewNamespace.Name = $Namespace
	$NewNamespace.Put()
    }

# Does Class Already Exist?
Write-Verbose "Getting $Class Class"
$ClassExist = Get-CimClass -Namespace root/$Namespace -ClassName $Class -ErrorAction SilentlyContinue
# Class Does Not Exist
If($ClassExist -eq $null){
    Write-Verbose "$Class class does not exist. Creating new class . . ."
    # Create Class
    $NewClass = New-Object System.Management.ManagementClass("root\$namespace", [string]::Empty, $null)
	$NewClass.name = $Class
    $NewClass.Qualifiers.Add("Static",$true)
    $NewClass.Qualifiers.Add("Description","$Class is a custom WMI Class created by Mark Godfrey(@geodesicz) to store BIOS Password Compliance Data.")
    $NewClass.Properties.Add("ComputerName",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("Model",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("Compliance",[System.Management.CimType]::String, $false)
    $NewClass.Properties["Compliance"].Qualifiers.Add("Description","The compliance property is a boolean to report compliance on whether or not the BIOS password is set to organization's standards.")
    $NewClass.Properties["ComputerName"].Qualifiers.Add("Key",$true)
    $NewClass.Put()
    }

# Write Class Attributes
$wmipath = 'root\'+$Namespace+':'+$class
$WMIInstance = ([wmiclass]$wmipath).CreateInstance()
$WMIInstance.ComputerName = $env:COMPUTERNAME
$WMIInstance.Model = $Model
$WMIInstance.Compliance = $Compliance
$WMIInstance.Put()
Clear-Variable -Name WMIInstance

    