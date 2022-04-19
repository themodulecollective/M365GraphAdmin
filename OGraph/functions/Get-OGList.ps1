Function Get-OGList
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists"
    Get-OGNextPage -uri $URI

}

