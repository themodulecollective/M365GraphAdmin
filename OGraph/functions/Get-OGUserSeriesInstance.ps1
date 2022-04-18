function Get-OGUserSeriesInstance
{
    param (
        [Parameter(Mandatory = $True)]$UserPrincipalName,
        [Parameter(Mandatory = $True)]$EventId,
        [Parameter(Mandatory = $True)][dateTime]$StartDateTime,
        [Parameter(Mandatory = $True)][datetime]$EndDateTime
    )
    $StartDateTime = $StartDateTime.ToString('o')
    $EndDateTime = $EndDateTime.ToString('o')
    $URI = "https://graph.microsoft.com/$GraphVersion/users/$userprincipalname/events/$EventId/instances?startDateTime=$StartDateTime&endDateTime=$EndDateTime"
    Get-OGNextPage -URI $URI
}