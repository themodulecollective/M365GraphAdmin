Function Get-OGGroupEvents
{
    
    param (
        [Parameter(Mandatory = $True)]$GroupId,
        [Parameter(Mandatory = $False)]$Filter
    )
    if ($filter)
    {

        $URI = "/$GraphVersion/groups/$GroupId/events?`$filter=$filter"
        Get-OGNextPage -URI $URI
    }
    else
    {
        $URI = "/$GraphVersion/groups/$GroupId/events"
        Get-OGNextPage -URI $URI
    }

}

