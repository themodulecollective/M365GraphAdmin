Function Get-OGGroupEvents
{
    
    param (
        [Parameter(Mandatory = $True)]$GroupId,
        [Parameter(Mandatory = $False)]$Filter
    )
    if ($filter)
    {

        $URI = "https://graph.microsoft.com/$GraphVersion/groups/$GroupId/events?`$filter=$filter"
        Get-OGNextPage -URI $URI
    }
    else
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/groups/$GroupId/events"
        Get-OGNextPage -URI $URI
    }

}

