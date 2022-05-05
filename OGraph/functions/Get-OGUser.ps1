<#
.SYNOPSIS
Get users

.DESCRIPTION
Get users with faster performance than mguser and all availible user properties in a PSObject

.PARAMETER UserPrincipalName
Search for userprincipalname

.PARAMETER SearchDisplayName
Search for users by displayname

.PARAMETER All
Get all users in tenant

.EXAMPLE
Get-OGUser -UserPrincipalName test@testaccount.onmicrosoft.com

.NOTES
General notes
#>
Function Get-OGUser {
    
    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param (
        [Parameter(Mandatory = $False,
            ParameterSetName = 'UPN')]$UserPrincipalName,
        [Parameter(Mandatory = $False,
            ParameterSetName = 'Search')]$SearchDisplayName,
        [Parameter(Mandatory = $False,
            ParameterSetName = 'All')][Switch]$All
    )
    if ($UserPrincipalName) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $Key" }
            URI         = "/$GraphVersion/users/$userprincipalname"
            Method      = 'GET'
            OutputType      = 'PSObject'
        }
        Invoke-GraphRequest @Account_params
    }
    if ($SearchDisplayName) {
        $URI = "/$GraphVersion/users?`$search=`"displayName:$SearchDisplayName`""
        Get-OGNextPage -uri $URI -SearchDisplayName
    }
    if ($All) {
        $URI = "/$GraphVersion/users"
        Get-OGNextPage -Uri $URI
    }
}