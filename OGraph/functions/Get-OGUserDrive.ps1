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
}