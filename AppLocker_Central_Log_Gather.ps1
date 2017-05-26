<#
AppLocker Log Collection Script V2.1
Written by Mark Godfrey @Geodesicz
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="LogPath")]
    [ValidateNotNullOrEmpty()]
    [string]$LogPath,

    [Parameter(Mandatory=$true,Position=2,HelpMessage="ClearAfterCollect")]
    [ValidateSet(
    'True',
    'False'
    )]
    [string]$ClearAfterCollect
)

# Format Log File
$Date = Get-Date -Format D
$LogFile = "$LogPath\$env:COMPUTERNAME-$Date.log"

# Check if Correct OS
$OS = Get-WmiObject win32_operatingsystem | select -ExpandProperty Caption

If($OS -like '*Enterprise*'){

    # Gather AppLocker Logs Where Item Did Not Run Correctly
    $EXE = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" -ErrorAction SilentlyContinue | ? {$_.ID -ne '8001' -and $_.ID -ne '8002'} | select TimeCreated,Message | fl
    If($EXE -ne $null){"Executable Logs" | Add-Content $LogFile; $EXE | Out-String | Add-Content $LogFile}

    $MSISCRIPT = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/MSI and SCRIPT" -ErrorAction SilentlyContinue| ? {$_.ID -ne '8005'} | select TimeCreated,Message | fl
    If($MSISCRIPT -ne $null){"MSI and Script Logs" | Add-Content $LogFile; $MSISCRIPT | Out-String | Add-Content $LogFile}

    $AppxDep = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/Packaged app-Deployment" -ErrorAction SilentlyContinue | ? {$_.ID -ne '8023'} | select TimeCreated,Message | fl
    If($AppxDep -ne $null){"AppX Deployment Logs" | Add-Content $LogFile; $AppxDep | Out-String | Add-Content $LogFile}

    $AppxExec = Get-WinEvent -LogName "Microsoft-Windows-AppLocker/Packaged app-Execution" -ErrorAction SilentlyContinue | ? {$_.ID -ne '8020'} | select TimeCreated,Message | fl
    If($AppxExec -ne $null){"AppX Execution Logs" | Add-Content $LogFile; $AppxExec | Out-String | Add-Content $LogFile}

    If($ClearAfterCollect -eq $true){
        # Clear Logs After Collection To Ensure Only Collected Once
        Wevtutil.exe cl "Microsoft-Windows-AppLocker/EXE and DLL"
        Wevtutil.exe cl "Microsoft-Windows-AppLocker/MSI and SCRIPT"
        Wevtutil.exe cl "Microsoft-Windows-AppLocker/Packaged app-Deployment"
        Wevtutil.exe cl "Microsoft-Windows-AppLocker/Packaged app-Execution"
        }

}
