Function Get-OGUserEvents {
    param (
        [Parameter(Mandatory = $True)]$UserPrincipalName,
        [Parameter(Mandatory = $False)]$Filter
    )
    if ($filter) {
        $URI = "/$GraphVersion/users/$userprincipalname/events?`$filter=$filter"
        Get-OGNextPage -URI $URI
    }
    else {
        $URI = "/$GraphVersion/users/$userprincipalname/events"
        Get-OGNextPage -URI $URI
    }
}