Function Add-OGGroupMember
{
    
    ## ToDo: Test UserObjectID param
    [CmdletBinding(DefaultParameterSetName = 'UOID')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'UOID')]
        [Parameter(ParameterSetName = 'UPN')]$GroupObjectID,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'UPN')]$UserPrincipalName,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'UOID')]$UserObjectID
    )
    if ($UserPrincipalName)
    {
        $UserObjectID = get-graphuser -UserPrincipalName $UserPrincipalName
    }
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$GroupObjectID/members/`$ref"
    $Body = [PSCustomObject]@{
        '@odata.id' = "https://graph.microsoft.com/$GraphVersion/directoryObjects/$($UserObjectID)"
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = $URI
        Body        = $Body | ConvertTo-Json
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

