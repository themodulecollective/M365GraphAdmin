<#
.SYNOPSIS
Get Azure AD Skus

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-OGSkus
{
    $account_params = @{
        Headers     = @{Authorization = "Bearer $Key" }
        Uri         = "/$GraphVersion/subscribedSkus"
        Method      = 'GET'
        OutputType = 'PSObject'
    }
    $Results = Invoke-GraphRequest @Account_params
    $Results.value
}