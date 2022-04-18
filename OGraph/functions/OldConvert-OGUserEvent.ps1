Function OldConvert-OGUserEvent
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
                type = $event.recurrence.pattern.type
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
        if ($event.recurrence.pattern.dayOfMonth)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'dayOfMonth' -Value $event.recurrence.pattern.dayOfMonth
        }
        if ($event.recurrence.pattern.daysOfWeek)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'daysOfWeek' -Value $event.recurrence.pattern.daysOfWeek
        }
        if ($event.recurrence.pattern.firstDayOfWeek)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'firstDayOfWeek' -Value $event.recurrence.pattern.firstDayOfWeek
        }
        if ($event.recurrence.pattern.index)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'index' -Value $event.recurrence.pattern.index
        }
        if ($event.recurrence.pattern.interval)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'interval' -Value $event.recurrence.pattern.interval
        }
        if ($event.recurrence.pattern.month)
        {
            $recurrence.pattern | Add-Member -MemberType NoteProperty -Name 'month' -Value $event.recurrence.pattern.month
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$($Event.organizer.emailaddress.address)/events"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

