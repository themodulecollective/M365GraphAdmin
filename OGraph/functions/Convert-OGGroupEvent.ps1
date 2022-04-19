Function Convert-OGGroupEvent
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][PSObject]$Event,
        [Parameter(Mandatory)][string]$GroupID,
        [Parameter(Mandatory = $false)][datetime]$CutOver
    )
    $Body = @{}
    if ($Event.subject)
    {
        $body.subject = $Event.subject
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
        $start = [PSCustomObject]@{
            dateTime = $Event.start.dateTime
            timeZone = $Event.start.timeZone
        }
        $body.start = $start
    }
    if ($Event.end)
    {
        $end = [PSCustomObject]@{
            dateTime = $Event.end.dateTime
            timeZone = $Event.end.timeZone
        }
        $body.end = $end
    }
    if ($event.recurrence)
    {
        $recurrence = [PSCustomObject]@{
            pattern = [PSCustomObject]@{
                type       = $event.recurrence.pattern.type
                interval   = $event.recurrence.pattern.interval
                daysOfWeek = @($event.recurrence.pattern.daysofweek)
            }
            range   = [PSCustomObject]@{
                type      = $event.recurrence.range.type
                startDate = $event.recurrence.range.startDate
            }
        }
        if ($CutOver)
        {
            [string]$CutOver = $CutOver.ToString('yyyy-MM-dd')
            $recurrence.range.startDate = $CutOver
        }
        if ($recurrence.range.type -ne 'noEnd')
        {
            $recurrence.range | Add-Member -MemberType NoteProperty -Name 'endDate' -Value $event.recurrence.range.endDate
        }
        $body.recurrence = $recurrence
    }
    if ($event.location.displayName)
    {
        $location = [PSCustomObject]@{
            displayName = $event.location.displayName
        }
        $body.location = $location
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
        $allowNewTimeProposals = $event.allowNewTimeProposals
        $body.allowNewTimeProposals = $allowNewTimeProposals
    }
    $body.isOnlineMeeting = 'true'
    $body.onlineMeetingProvider = 'teamsForBusiness'

    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/groups/$GroupID/events"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

