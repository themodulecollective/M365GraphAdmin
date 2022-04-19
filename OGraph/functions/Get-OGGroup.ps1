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
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            URI         = "https://graph.microsoft.com/$GraphVersion/groups/$ObjectID"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($SearchDisplayName)
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/groups?`$search=`"displayName:$SearchDisplayName`""
        Get-OGNextPage -uri $URI -SearchDisplayName
    }
    if ($All)
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/groups"
        Get-OGNextPage -Uri $URI
    }

}

