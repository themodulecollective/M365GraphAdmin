<#
.SYNOPSIS
Get user OneDrive Meta information

.DESCRIPTION
Long description

.PARAMETER UserPrincipalName
Userprincipalname or ID for lookup

.EXAMPLE
Get-OGUserDrive -userprincipalname test.user@domain.com
.NOTES
General notes
#>
Function Get-OGUserDrive {
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    if ($UserPrincipalName) {
        $account_params = @{
            URI        = "https://graph.microsoft.com/$GraphVersion/users/$userprincipalname/drive"
            Method     = 'GET'
            outputtype = 'psobject'
        }
        Invoke-GraphRequest @Account_params
    }
}Function Get-OGUserDrive {
    
    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param (
        [Parameter(Mandatory = $False,
            ParameterSetName = 'UPN')]$UserPrincipalName
    )
    if ($UserPrincipalName) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $Key" }
            URI         = "/$GraphVersion/users/$userprincipalname/Drive"
            Method      = 'GET'
            OutputType  = 'PSObject'
            ContentType = 'application/json'
        }
        Invoke-GraphRequest @Account_params
    }
}