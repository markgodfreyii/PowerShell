$SiteServer = "TEKU-CM.TEKUITS.COM"

# Credential Prompt
$creds = Get-Credential -Message "Enter Credentials to Access Configuration Manager"

# Create SMS Task Sequence Object to Access TS Environment
$TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment -Verbose

# Query SMS Provider for Site Code While Verifying Credentials and Permissions
If($SMSProv = Get-WmiObject -ComputerName $SiteServer -Namespace 'root/sms' `
    -Query "select sitecode from sms_providerlocation where providerforlocalsite = 'True'" -Credential $creds -Verbose){$ConnectSuccess = $true}
While($ConnectSuccess -ne $true){
    $creds = Get-Credential -Message "Enter Credentials to Access Configuration Manager" -Verbose
    If($SMSProv = Get-WmiObject -ComputerName $SiteServer -Namespace 'root/sms' `
        -Query "select sitecode from sms_providerlocation where providerforlocalsite = 'True'" -Credential $creds -Verbose){$ConnectSuccess = $true}
}
$SiteCode = $SMSProv.sitecode

# Format Namespace for WQL Queries
$Namespace = "root\sms\site_$sitecode"

# Define Functions
function Query-CMWQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullorEmpty()]
        [String]$WQLQuery
    )

    Get-WmiObject -ComputerName $SiteServer -Namespace $Namespace -Query $WQLQuery -Credential $creds -Verbose
}

$Groups = $User.SecurityGroupName
$Domain = ($Groups.split("\"))[0]
$Groups = $Groups.replace("$Domain\","")

$Apps = @()
$Groups | ForEach-Object{
    $CMApp = Query-CMWQL -WQLQuery "select * from sms_deploymentinfo where collectionname = '$PSitem' and targetsecuritytypeid = '31'"
    If($CMApp -ne $null){$Apps += $CMApp.TargetName}         
}

[int32]$var = '1'
$Apps | ForEach-Object{
    If($Var.length -eq '1'){$TSEnv.Value("APP0$var") = "$PSitem"}
    else{$TSEnv.Value("APP$var") = "$PSItem"}
    $var++
}