<# 
.SYNOPSIS 
Identify Configuration Manager Content from PackageID in Errors and Log Files 
.DESCRIPTION 
Uses PackageID to Identify Content Type and Other Descriptive Information About Content, Requires  - Created by Mark Godfrey @Geodesicz
.PARAMETER SiteServer 
The computer name of your Configuration Manager site server to query
.PARAMETER SiteCode 
The Site Code of your Configuration Manager site to query
.PARAMETER PackageID
The PackageID of the Content you are attempting to identify
.EXAMPLE 
.\Identify-Content.ps1 -SiteServer 'teku-cm' -SiteCode 'PS1' -PackageID 'PS10008B' -Verbose
.LINK
http://www.tekuits.com 
#> 

[CmdletBinding()]
Param(
    [Parameter(HelpMessage="SiteServer")]
    [ValidateNotNullOrEmpty()]
    [String]$SiteServer,

    [Parameter(HelpMessage="SiteCode")]
    [ValidateNotNullOrEmpty()]
    [String]$SiteCode,

    [Parameter(Mandatory=$true,HelpMessage="PackageID")]
    [ValidateNotNullOrEmpty()]
    [String]$PackageID

)

If($siteserver -eq $null -or $SiteCode -eq $null){
    # Import Configuration Manager Module
    Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")

    # Get Site Information
    $siteserver = Get-PSDrive -PSProvider CMSite | select -ExpandProperty Root
    $sitecode = Get-PSDrive -PSProvider CMSite | select -ExpandProperty Name
}

If($siteserver -eq $null -or $SiteCode -eq $null){Write-Error "SiteServer or SiteCode variables not defined. Either specify as parameters or run on system with Configuration Manager Module to automatically import."}

# Define Namespace from Site Code
Write-Verbose "Defining Namespace From Site Code"
$Namespace = "root\sms\site_$sitecode"

# Functions
function Query-CMWQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullorEmpty()]
        [String]$WQLQuery
    )

    Get-WmiObject -ComputerName $SiteServer -Namespace $Namespace -Query $WQLQuery
}

# Check if Package
Write-Verbose "Checking if Content is a Package"
$Package = Query-CMWQL "SELECT * from sms_package where packageid = '$PackageID'"
If($Package -ne $null){
    $ObjectType = 'Package'
    $Object = $Package
    Write-Verbose "Content Type Identified"
}

If($ObjectType -eq $null){
    # Check if Application
    Write-Verbose "Checking if Content is an Application"
    $Application = Query-CMWQL "SELECT * from sms_contentpackage where packageid = '$PackageID'"
    If($Application -ne $null){
        $ObjectType = 'Application'
        $Object = $Application
        Write-Verbose "Content Type Identified"
    }
}

If($ObjectType -eq $null){
    # Check if Boot Image
    Write-Verbose "Checking if Content is a Boot Image"
    $BootImage = Query-CMWQL "SELECT * from sms_bootimagepackage where packageid = '$PackageID'"
    If($BootImage -ne $null){
        $ObjectType = 'Boot Image'
        $Object = $BootImage
        Write-Verbose "Content Type Identified"
    }
}

If($ObjectType -eq $null){
    # Check if OS Image
    Write-Verbose "Checking if Content is an Operating System Image"
    $OSImage = Query-CMWQL "SELECT * from sms_imagepackage where packageid = '$PackageID'"
    If($OSImage -ne $null){
        $ObjectType = 'Operating System Image'
        $Object = $OSImage
        Write-Verbose "Content Type Identified"
    }
  
}

If($ObjectType -eq $null){
    # Check if Software Update Package
    Write-Verbose "Checking if Content is a Software Update Package"
    $SUP = Query-CMWQL "SELECT * from sms_softwareupdatespackage where packageid = '$PackageID'"
    If($SUP -ne $null){
        $ObjectType = 'Software Update Package'
        $Object = $SUP
        Write-Verbose "Content Type Identified"
    }
  
}

If($ObjectType -eq $null){
    # Check if Driver Package
    Write-Verbose "Checking if Content is a Driver Package"
    $DrvPkg = Query-CMWQL "SELECT * from sms_driverpackage where packageid = '$PackageID'"
    If($DrvPkg -ne $null){
        $ObjectType = 'Driver Package'
        $Object = $DrvPkg
        Write-Verbose "Content Type Identified"
    }
  
}

If($ObjectType -eq $null){
    # Check if Operating System Upgrade/Install Package
    Write-Verbose "Checking if Content is an Operating System Upgrade/Install Package"
    $OSUpgPkg = Query-CMWQL "SELECT * from sms_operatingsysteminstallpackage where packageid = '$PackageID'"
    If($OSUpgPkg -ne $null){
        $ObjectType = 'Operating System Upgrade/Install Package'
        $Object = $OSUpgPkg
        Write-Verbose "Content Type Identified"
    }
  
}

If($ObjectType -eq $null){
    # Check if Virtual Hard Disk
    Write-Verbose "Checking if Virtual Hard Disk"
    $VHD = Query-CMWQL "SELECT * from sms_vhdpackage where packageid = '$PackageID'"
    If($VHD -ne $null){
        $ObjectType = 'Virtual Hard Disk'
        $ObjectType = $VHD
        Write-Verbose "Content Type Identified"
    }
  
}

# Feedback
If($ObjectType -eq $null){Write-Error "Unable to Identify Content"}
else{
    Write-Verbose "Content Type is $ObjectType"
    $Object
}