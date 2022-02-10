## New Tenant Users
$ApplicationID = "f6557fc2-d4a5-4266-8f4c-2bdcd0cd9a2d"
$TenantId = "126ccd5c-dfff-496c-a52c-bf3844d430ec"
$AccessSecret = 'TQ-7Q~lXEafuQ3v0i6nP~-fRak2OmCRNHUDLk'
Get-OGAPIKey -ApplicationID $ApplicationID -TenantId $TenantId -AccessSecret $AccessSecret
# Get New Tenant Users
$UsersNewTenant = Get-OGUser -All
# Filter for events on type,startdate, and isOrganizer
$FilterIndividualEvents = "type eq 'singleInstance' and start/dateTime ge '2020-10-07' and isorganizer eq true"
$FilterSeriesEvents = "type eq 'seriesMaster' and start/dateTime ge '2020-10-07' and isorganizer eq true"
# The property 'isOnlineMeeting' does not support filtering. This will be handled in a foreach below
foreach ($UserNewTenant in $UsersNewTenant) {
    # Get Individual Events for each user using filter
    $IndividualEvents = Get-OGUserEvents -UserPrincipalName $UsersNewTenant -Filter $FilterIndividualEvents
    foreach ($IndividualEvent in $IndividualEvents) {
        # Filter for Online meeting
        if ($IndividualEvent.isOnlineMeeting -eq $true) {
            # Remove Teams Meeting Info from Event Body
            $UpdatedIndividualBody = Remove-OGTeamsEventInfo -html $IndividualEvent.body.content
        }
    }
    $SeriesEvents = Get-OGUserEvents -UserPrincipalName $UsersNewTenant -Filter $FilterSeriesEvents
    foreach ($SeriesEvent in $SeriesEvents) {
        # Filter for Online meeting
        if ($SeriesEvent.isOnlineMeeting -eq $true) {
            # Remove Teams Meeting Info from Event Body
            $UpdatedSeriesBody = Remove-OGTeamsEventInfo -html $SeriesEvent.body.content}
    }
}

new-oguserevent -subject -message -