<#
.SYNOPSIS
Get Azure AD skus for individual user

.DESCRIPTION
Long description

.PARAMETER UserPrincipalName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-OGUserSkus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    $user = Get-OGUser -UserPrincipalName $UserPrincipalName
    $account_params = @{
        Headers    = @{Authorization = "Bearer $Key" }
        Uri        = "$GraphVersion/Users/$($user.Id)/licenseDetails"
        Method     = 'GET'
        OutputType = 'PSObject'
    }
    $Results = Invoke-GraphRequest @Account_params
    $Results.value
}