<#
Write Dell Warranty Information to WMI V2.2
Queries Dell Web Service API V4 for Warranty Info
Creates Custom WMI Namespace and Class
Writes Warranty Info to WMI
Requires PowerShell V5
---------------
You can also add this custom class to be collected by Configuration Manager hardware inventory
---------------
Script written by Mark Godfrey (http://www.tekuits.com/blog) and Gary Blok (http://garytown.com/) - MN.IT
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="APIKey")]
    [ValidateNotNullOrEmpty()]
    [string]$APIkey 
)

# Get Service Tag of Local Machine
$ServiceTag = Get-WmiObject -Class Win32_Bios | select -ExpandProperty SerialNumber
       
# Query Web Service API
Try
{
    $URL1 = "https://api.dell.com/support/assetinfo/v4/getassetwarranty/$ServiceTag"
    $URL2 = "?apikey=$apikey" 
    $URL = $URL1 + $URL2
    $Request = Invoke-RestMethod -URI $URL -Method GET
}
Catch [System.Exception]
{
    Write-Output "Production API URL failed, switching to sandbox API"
    $URL1 = "https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty/$ServiceTag"
    $URL2 = "?apikey=$apikey" 
    $URL = $URL1 + $URL2
    $Request = Invoke-RestMethod -URI $URL -Method GET
}

$Warranties = $Request.AssetWarrantyResponse.assetentitlementdata | where ServiceLevelDescription -NE 'Dell Digitial Delivery'
$AssetDetails = $Request.AssetWarrantyResponse.assetheaderdata

# Set Vars for WMI Info
$Namespace = 'ITLocal'
$Class = 'Warranty_Info'

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
    $NewClass.Qualifiers.Add("Description","Warranty_Info is a custom WMI Class created by Gary Blok(@gwblok) and Mark Godfrey(@geodesicz) to store Dell warranty information from Dell's Warranty API.")
    $NewClass.Properties.Add("ComputerName",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("Model",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("ServiceTag",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("ServiceLevelDescription",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("ServiceProvider",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("StartDate",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("EndDate",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("ItemNumber",[System.Management.CimType]::String, $false)
    $NewClass.Properties["ItemNumber"].Qualifiers.Add("Key",$true)
    $NewClass.Put()
}

# Write Class Attributes
If($Warranties -ne $null){
    $Warranties | ForEach{
        $wmipath = 'root\'+$Namespace+':'+$class
        $WMIInstance = ([wmiclass]$wmipath).CreateInstance()
        $WMIInstance.ComputerName = $env:COMPUTERNAME
        $WMIInstance.Model = "Dell " + ($AssetDetails.MachineDescription)
        $WMIInstance.ServiceTag = $AssetDetails.ServiceTag
        $WMIInstance.ServiceLevelDescription = $PSItem.ServiceLevelDescription
        $WMIInstance.ServiceProvider = $PSItem.ServiceProvider
        $WMIInstance.StartDate = ($PSItem.StartDate).Replace("T00:00:00","")
        $WMIInstance.EndDate = ($PSItem.EndDate).Replace("T23:59:59","")
        $WMIInstance.ItemNumber = $PSItem.ItemNumber
        $WMIInstance.Put()
        Clear-Variable -Name WMIInstance
    }
}
else{
    $wmipath = 'root\'+$Namespace+':'+$class
    $WMIInstance = ([wmiclass]$wmipath).CreateInstance()
    $WMIInstance.ComputerName = $env:COMPUTERNAME
    $WMIInstance.Model = "Dell " + ((Get-WmiObject win32_computersystem).Model)
    $WMIInstance.ServiceTag = ((Get-WmiObject win32_bios).SerialNumber)
    $WMIInstance.ServiceLevelDescription = $null
    $WMIInstance.ServiceProvider = $null
    $WMIInstance.StartDate = $null
    $WMIInstance.EndDate = $null
    $WMIInstance.ItemNumber = 'No Warranty'
    $WMIInstance.Put()
}