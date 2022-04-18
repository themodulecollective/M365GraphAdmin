Function Get-OGListColumns
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/Columns"
    Get-OGNextPage -uri $URI

}

