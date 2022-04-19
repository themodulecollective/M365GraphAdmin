Function Get-OGListItem
{
    
    ## ToDo: Wrap in psobject to include weburl,createdby etc with fields
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory = $false)]$ItemId
    )
    if ($ItemId)
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items?expand=fields"
        $response = Get-OGNextPage -uri $URI | Where-Object id -EQ $ItemId
        $response.fields
    }
    else
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items?expand=fields"
        $response = Get-OGNextPage -uri $URI
        $response.fields
    }

}

