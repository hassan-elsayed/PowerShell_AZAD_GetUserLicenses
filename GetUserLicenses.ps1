<#PSScriptInfo
.VERSION 1.0.0
.AUTHOR Hassan Elsayed - Twitter @HassanElSayed | Nic Aguilar - Twitter @kcin_au
.TAGS MSOL Office365 Licenses
.LICENSEURI https://github.com/hassan-elsayed/PowerShell_AZAD_GetUserLicenses/blob/master/LICENSE
.EXTERNALMODULEDEPENDENCIES Microsoft Online Services Sign-In Assistant for IT Professionals RTW, Azure Active Directory Module for Windows PowerShell
 - Install-Module MSOnline
 - Install-Module AzureAD
.RELEASENOTES
 Included External Module Dependencies in metadata.
.DESCRIPTION
 This script will export a list of all Microsoft licenses tied to your account.
#> 

# Import Module to this session
Import-Module AzureAD

# Run once
# Connect-AzAccount
# Connect-MSOlService

# Targeted Folder
$myFolder = "C:\Users\$env:UserName\Desktop\"
# Report 1: All Users with their Licenses
$Header = "UserPrincipalName, DisplayName, LicenseAssigned"
$Data = @()
$OutputFile = $myFolder+"LicensesReport_1_$((Get-Date -uformat %Y%m%d%H%M%S).ToString()).csv"
Out-File -FilePath $OutputFile -InputObject $Header -Encoding UTF8 -append
# Report 2: Overview Count on All Licenses
$Header2 = "AccountSkuId, ActiveUnits, WarningUnits, ConsumedUnits"
$Data2 = @()
$OutputFile2 = $myFolder+"LicensesReport_2_$((Get-Date -uformat %Y%m%d%H%M%S).ToString()).csv"
Out-File -FilePath $OutputFile2 -InputObject $Header2 -Encoding UTF8 -append

$AccountNamePrefix = (Get-MsolAccountSku).AccountSkuId[0].split(":")[0]+":"

# Report 1
$users = Get-MSolUser -All

foreach($user in $users)
{
	$UPN = $User.UserPrincipalName
	$DisplayName = $User.DisplayName
	$Licenses = $User.Licenses.accountskuid
    $LicenseCount = $Licenses.Count.ToString()
    $myLicenses = ""

    foreach($License in $Licenses)
    {
        $myLicenses = $myLicenses+", "+$License
    }
    $LicenseAssigned = $LicenseCount+", "+$myLicenses.Replace($AccountNamePrefix,"")

	$Data = ($UPN + "," + $DisplayName + "," + $LicenseAssigned)
	Out-File -FilePath $OutputFile -InputObject $Data -Encoding UTF8 -append
}

# Report 2
$LicensedAccounts = Get-MsolAccountSku

foreach($LicensedAccount in $LicensedAccounts)
{
    $AccountSkuId = ($LicensedAccount).AccountSkuId.Replace($AccountNamePrefix,"")
    $ActiveUnits = ($LicensedAccount).ActiveUnits
    $WarningUnits = ($LicensedAccount).WarningUnits
    $ConsumedUnits = ($LicensedAccount).ConsumedUnits

    $Data2 = ($AccountSkuId + "," + $ActiveUnits + "," + $WarningUnits + "," + $ConsumedUnits)
    Out-File -FilePath $OutputFile2 -InputObject $Data2 -Encoding UTF8 -append
}
