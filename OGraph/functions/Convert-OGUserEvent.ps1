Function Convert-OGUserEvent
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][PSObject]$Event,
        [Parameter(Mandatory = $false)][datetime]$CutOver,
        [Parameter(Mandatory)][string]$SubjectAppend

    )
    $Body = @{}
    if ($Event.subject)
    {
        if ($SubjectAppend)
        {
            $Subject = $SubjectAppend + ' - ' + $Event.subject
        }
        else
        {
            $Subject = $Event.subject
        }
        $body.subject = $Subject
    }
    if ($Event.body.content)
    {
        $updateContent = Remove-OGTeamsEventInfo -html $Event.body.content
        $bodyContent = [PSCustomObject]@{
            contentType = 'HTML'
            content     = $updateContent
        }
        $body.body = $bodycontent
    }
    if ($Event.start)
    {
        $body.start = $Event.start
    }
    if ($Event.end)
    {
        $body.end = $Event.end
    }
    if ($event.recurrence)
    {
        $recurrence = $event.recurrence
        if ($CutOver)
        {
            [string]$CutOver = $CutOver.ToString('yyyy-MM-dd')
            $recurrence.range.startDate = $CutOver
        }
        $body.recurrence = $event.recurrence
    }
    if ($event.location)
    {
        $body.location = $event.location
    }
    if ($event.attendees)
    {
        $array = @(
            foreach ($attendeeItem in $event.attendees)
            {
                $attendees = @{}
                $emailAddress = [PSCustomObject]@{
                    address = $attendeeItem.emailAddress.address
                    name    = $attendeeItem.emailAddress.name
                }
                $attendees.emailaddress = $emailAddress
                $type = $attendeeItem.type
                $attendees.type = $type
                $attendees
            })
        $body.attendees = $array
    }
    if ($event.allowNewTimeProposals)
    {
        $body.allowNewTimeProposals = $event.allowNewTimeProposals
    }
    if ($event.isOnlineMeeting)
    {
        $body.isOnlineMeeting = $event.isOnlineMeeting
    }
    if ($event.onlineMeetingProvider)
    {
        $body.onlineMeetingProvider = $event.onlineMeetingProvider
    }
    if ($event.hideAttendees)
    {
        $body.hideAttendees = $event.hideAttendees
    }
    if ($event.isAllDay)
    {
        $body.isAllDay = $event.isAllDay
    }
    if ($event.locations)
    {
        $body.locations = $event.locations
    }
    if ($event.originalStart)
    {
        $body.originalStart = $event.originalStart
    }
    if ($event.originalStartTimeZone)
    {
        $body.originalStartTimeZone = $event.originalStartTimeZone
    }
    if ($event.reminderMinutesBeforeStart)
    {
        $body.reminderMinutesBeforeStart = $event.reminderMinutesBeforeStart
    }
    if ($event.responseRequested)
    {
        $body.responseRequested = $event.responseRequested
    }
    if ($event.sensitivity)
    {
        $body.sensitivity = $event.sensitivity
    }
    if ($event.showAs)
    {
        $body.showAs = $event.showAs
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$($Event.organizer.emailaddress.address)/events"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

