Function Remove-OGGroupMember
{
    
    ## ToDo: Replace GroupID with ObjectId for consistency
    ## ToDo: Replace Member with UserPrincipalName
    ## ToDo: Add UserObjectID param    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$GroupID,
        [Parameter(Mandatory)]$Member
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$groupID/members/$Member/`$ref"
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = $URI
        Method      = 'DELETE'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

