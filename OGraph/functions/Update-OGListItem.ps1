Function Update-OGListItem
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$ListItemId,
        [Parameter(Mandatory)]$ItemUpdates
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items/$ListItemId/fields"
        Body        = $ItemUpdates | ConvertTo-Json -Depth 5
        Method      = 'PATCH'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
    # $ItemUpdates | ConvertTo-Json -Depth 5

}

