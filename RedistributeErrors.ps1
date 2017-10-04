<# 
.SYNOPSIS 
Trigger Redistribution of Distribution Jobs with Errors - Alpha V0.2
.DESCRIPTION 
Redistribute all Distribution Jobs with Errors, Will Update Content on All DPs to which content
 is currently targetted for distribution - Created by Mark Godfrey @Geodesicz
.PARAMETER SiteServer 
The computer name of your Configuration Manager site server to query
.PARAMETER SiteCode 
The Site Code of your Configuration Manager site to query
.EXAMPLE 
.\RedistributeErrors.ps1 -SiteServer 'teku-cm' -SiteCode 'PS1' -Verbose
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
    [String]$SiteCode
)

If($siteserver -eq $null -or $SiteCode -eq $null){
    # Import Configuration Manager Module
    Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")

    # Get Site Information
    $siteserver = Get-PSDrive -PSProvider CMSite | select -ExpandProperty Root
    $sitecode = Get-PSDrive -PSProvider CMSite | select -ExpandProperty Name
}

If($siteserver -eq $null -or $SiteCode -eq $null){Write-Error "SiteServer or SiteCode variables not defined. Either specify as parameters or run on system with Configuration Manager Module to automatically import.";Exit}

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

# Get Failed Distribution Jobs
Write-Verbose "Retrieving Failed Distribution Jobs"
$FailedJobs = Query-CMWQL -WQLQuery "select PackageID,ObjectTypeID from sms_distributionstatus where Type = '3' or Type = '4'" -Verbose

If($FailedJobs -eq $null){Write-Verbose "No Failed Distribution Jobs Found"}
Else{

    $JobCount = $FaildJobs.Count
    Write-Verbose "$JobCount Failed Distribution Jobs Found"

    # For Each Failed Job, Identify Content Type and Trigger Redistribution
    Write-Verbose "Identifying Content Types for Failed Jobs and Triggering Redistribution"
    $FailedJobs | ForEach {

        $ObjType = $PSitem.ObjectTypeID
        $PkgID = $PSItem.PackageID
        Write-Verbose "PackageID $PkgID has a Content Type of $ObjType"
        Write-Verbose "Identifying Corresponding Object Type for $ObjType"

        # Package
        If($ObjType -eq '2'){
        
            Write-Verbose "$PkgID is a Package. Grabbing SMS_Package Object"
            $Package = Query-CMWQL -WQLQuery "SELECT * from sms_package where packageid = '$PkgID'"
            If($Package -eq $null){Write-Error "Unable to find SMS_Package Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $Package.RefreshPkgSource()
            }
        }

        # OS Install Package
        If($ObjType -eq '14'){
        
            Write-Verbose "$PkgID is an OS Install Package. Grabbing SMS_OperatingSystemInstallPackage Object"
            $OSInstPkg = Query-CMWQL -WQLQuery "SELECT * from sms_operatingsysteminstallpackage where packageid = '$PkgID'"
            If($OSInstPkg -eq $null){Write-Error "Unable to find SMS_OperatingSystemInstallPackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $OSInstPkg.RefreshPkgSource()
            }
        }

        # Image
        If($ObjType -eq '18'){
        
            Write-Verbose "$PkgID is an Image. Grabbing SMS_ImagePackage Object"
            $ImgPkg = Query-CMWQL -WQLQuery "SELECT * from sms_imagepackage where packageid = '$PkgID'"
            If($ImgPkg -eq $null){Write-Error "Unable to find SMS_ImagePackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $ImgPkg.RefreshPkgSource()
            }
        }

        # Boot Image
        If($ObjType -eq '19'){
        
            Write-Verbose "$PkgID is a Boot Image. Grabbing SMS_BootImagePackage Object"
            $BootImgPkg = Query-CMWQL -WQLQuery "SELECT * from sms_bootimagepackage where packageid = '$PkgID'"
            If($BootImgPkg -eq $null){Write-Error "Unable to find SMS_BootImagePackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $BootImgPkg.RefreshPkgSource()
            }
        }

        # Device Setting Package
        If($ObjType -eq '21'){
        
            Write-Verbose "$PkgID is a Device Setting Package. Grabbing SMS_DeviceSettingPackage Object"
            $DevSetPkg = Query-CMWQL -WQLQuery "SELECT * from sms_devicesettingpackage where packageid = '$PkgID'"
            If($DevSetPkg -eq $null){Write-Error "Unable to find SMS_DeviceSettingPackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $DevSetPkg.RefreshPkgSource()
            }
        }

        # Driver Package
        If($ObjType -eq '23'){
        
            Write-Verbose "$PkgID is a Driver Package. Grabbing SMS_DriverPackage Object"
            $DrvPkg = Query-CMWQL -WQLQuery "SELECT * from sms_driverpackage where packageid = '$PkgID'"
            If($DrvPkg -eq $null){Write-Error "Unable to find SMS_DriverPackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $DrvPkg.RefreshPkgSource()
            }
        }

        # Software Update Package
        If($ObjType -eq '24'){
        
            Write-Verbose "$PkgID is a Software Update Package. Grabbing SMS_SoftwareUpdatesPackage Object"
            $SWUpdPkg = Query-CMWQL -WQLQuery "SELECT * from sms_SoftwareUpdatespackage where packageid = '$PkgID'"
            If($SWUpdPkg -eq $null){Write-Error "Unable to find SMS_SoftwareUpdatesInstallPackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $SWUpdPkg.RefreshPkgSource()
            }
        }

        # Application
        If($ObjType -eq '31'){
        
            Write-Verbose "$PkgID is an Application. Grabbing SMS_ContentPackage Object"
            $App = Query-CMWQL -WQLQuery "SELECT * from sms_contentpackage where packageid = '$PkgID'"
            If($App -eq $null){Write-Error "Unable to find SMS_ContentPackage Object for $PkgID" -Verbose}
            Else{
                Write-Verbose "Attempting to trigger Content Dedistribution for $PkgID"
                $App.RefreshPkgSource()
            }
        }
        
    }
}


