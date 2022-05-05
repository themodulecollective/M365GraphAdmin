<#
.SYNOPSIS
Get groups from Azure AD
.DESCRIPTION
Long description

.PARAMETER ObjectID
Parameter description

.PARAMETER SearchDisplayName
Parameter description

.PARAMETER All
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-OGGroup
{
    [CmdletBinding(DefaultParameterSetName = 'OID')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'OID')]$ObjectID,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Search')]$SearchDisplayName,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'All')][Switch]$All
    )
    if ($ObjectID)
    {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $Key" }
            URI         = "/$GraphVersion/groups/$ObjectID"
            Method      = 'GET'
            OutputType      = 'PSObject'
        }
        Invoke-GraphRequest @Account_params
    }
    if ($SearchDisplayName)
    {
        $URI = "/$GraphVersion/groups?`$search=`"displayName:$SearchDisplayName`""
        Get-OGNextPage -uri $URI -SearchDisplayName
    }
    if ($All)
    {
        $URI = "/$GraphVersion/groups"
        Get-OGNextPage -Uri $URI
    }
}