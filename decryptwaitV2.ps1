<# 
.SYNOPSIS 
    Decrypt C Drive and Wait For Finish 
.DESCRIPTION 
    Decrypts the C Drive and outputs encryption percentage status until decryption completes
.Notes
    Author: Mark Godfrey
    Version: 2.0
    Twitter: @Geodesicz
    Blog: http://www.tekuits.com
.EXAMPLE 
.\decryptwaitv2.ps1
.LINK
http://www.tekuits.com 
#> 

# Decrypt
$encryption = Get-WmiObject -Namespace root/cimv2/security/microsoftvolumeencryption -Class win32_encryptablevolume -Filter {DriveLetter = 'C:'}
$encryption.Decrypt()

# Wait for Finish
$Percent = ($encryption.GetConversionStatus()).EncryptionPercentage
While($Percent -ne '0'){
    Write-Host "Decrypting..."
    Write-Host $percent
    Start-Sleep -Seconds 10
    $encryption = Get-WmiObject -Namespace root/cimv2/security/microsoftvolumeencryption -Class win32_encryptablevolume -Filter {DriveLetter = 'C:'}
    $Percent = ($encryption.GetConversionStatus()).EncryptionPercentage
}
If($Percent -eq '0'){
    Write-Host "Drive has finished decrypting."
}