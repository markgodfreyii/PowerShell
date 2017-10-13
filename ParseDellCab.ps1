<# 
.SYNOPSIS 
Download and Parse Dell Downloads from CAB V1.1 - To be used in conjunction with other code for Dell Deployment Solutions
.DESCRIPTION 
Download and Parse Dell Downloads from CAB V1.1 - Created by Mark Godfrey @Geodesicz
.LINK
http://www.tekuits.com
#> 

# Format Cab DL Path
$CabPath = "$PSScriptRoot\dellsdpcatalogpc.cab"

# Download Dell Cab File
Invoke-WebRequest -Uri "http://ftp.dell.com/catalog/dellsdpcatalogpc.cab" -OutFile $CabPath -Verbose

# Extract XML from Cab File
If(Test-Path "$PSScriptRoot\DellSDPCatalogPC.xml"){Remove-Item -Path "$PSScriptRoot\DellSDPCatalogPC.xml" -Force -Verbose}
<#
$shell = New-Object -Comobject shell.application
$Items = $shell.Namespace($CabPath).items()
$Extract = $shell.Namespace($PSScriptRoot)
$Extract.CopyHere($Items)
#>
Expand $CabPath "$PSScriptRoot\DellSDPCatalogPC.xml"

# Import and Create XML Object
[xml]$XML = Get-Content $PSScriptRoot\DellSDPCatalogPC.xml -Verbose

# Create Array of Downloads
$Downloads = $xml.SystemsManagementCatalog.SoftwareDistributionPackage

# Display List of Available Downloads
# $Names = $Downloads | ForEach {$PSItem.LocalizedProperties.Title}

# Find Target Download for Specific Desired Function (Example)
$Model = (Get-WmiObject win32_computersystem).Model
If(!($Model.EndsWith("AIO")) -or !($Model.EndsWith("M"))){
    $Target = $Downloads | Where-Object -FilterScript {
        $PSitem.LocalizedProperties.Title -match $model -and $PSitem.LocalizedProperties.Title -notmatch $model + " AIO" -and $PSitem.LocalizedProperties.Title -notmatch $model + "M"
    }
}
Else{$Target = $Downloads | Where-Object -FilterScript {$PSitem.LocalizedProperties.Title -match $model}}
$TargetLink = $Target.InstallableItem.OriginFile.OriginUri
$TargetFileName = $Target.InstallableItem.OriginFile.FileName
Invoke-WebRequest -Uri $TargetLink -OutFile $PSScriptRoot\$TargetFileName -UseBasicParsing -Verbose
$TargetDownload = "$PSScriptRoot\$TargetFileName"
