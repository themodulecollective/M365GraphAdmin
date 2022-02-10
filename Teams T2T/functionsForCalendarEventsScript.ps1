$Script:GraphVersion = "v1.0"

function Get-OGNextPage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$URI,
        [Switch]$SearchDisplayName
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        URI         = $URI
        Method      = 'GET'
        ContentType = 'application/json'
    }
    if ($SearchDisplayName) {
        $account_params.headers.add("ConsistencyLevel", "eventual")
    }
    $Result = Invoke-RestMethod @Account_params
    if ($results."@odata.nextlink") {
        Get-OGNextPage -Uri $results."@odata.nextlink"
    }
    elseif (!$results."@odata.nextlink") {
        $Result.Value
    }
}
function Get-OGAPIKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ApplicationID,
        [Parameter(Mandatory)]$TenantId,
        [Parameter(Mandatory)]$AccessSecret
    )
    $Body = @{    
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $ApplicationID
        Client_Secret = $AccessSecret
    } 
    $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $Body
    $Script:GraphAPIKey = $ConnectGraph.access_token
}
function Get-OGUser {
    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param (
        [Parameter(Mandatory = $False,
            ParameterSetName = 'UPN')]$UserPrincipalName,
        [Parameter(Mandatory = $False,
            ParameterSetName = 'Search')]$SearchDisplayName,
        [Parameter(Mandatory = $False,
            ParameterSetName = 'All')][Switch]$All
    )
    if ($UserPrincipalName) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            URI         = "https://graph.microsoft.com/$GraphVersion/users/$userprincipalname"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($SearchDisplayName) {
        $URI = "https://graph.microsoft.com/$GraphVersion/users?`$search=`"displayName:$SearchDisplayName`""
        Get-OGNextPage -uri $URI -SearchDisplayName
    }
    if ($All) {
        $URI = "https://graph.microsoft.com/$GraphVersion/users"
        Get-OGNextPage -Uri $URI
    }   
}
function Get-OGUserEvents {
    param (
        [Parameter(Mandatory = $True)]$UserPrincipalName,
        [Parameter(Mandatory = $False)]$Filter
    )
    if ($filter) {
        
        $URI = "https://graph.microsoft.com/$GraphVersion/users/$userprincipalname/events?`$filter=$filter"
        Get-OGNextPage -URI $URI
    }
    else {
        $URI = "https://graph.microsoft.com/$GraphVersion/users/$userprincipalname/events"
        Get-OGNextPage -URI $URI
    }
}
function Remove-OGTeamsEventInfo {
    param (
        [Parameter(Mandatory = $True)]$html
    )
    $stringbyline = $html -split "`r`n" 
    $Underscores = $stringbyline | Select-String "________________________________________________________________________________"
    if ($Underscores) {
        $Startline = $Underscores[0].LineNumber - 2
        $Endline = $Underscores[1].LineNumber
        $expectedContent = $stringbyline[$Startline..$Endline] | Select-String -simplematch "teams.microsoft.com"
        if ($expectedContent) {
            $TotalLines = $stringbyline.count - 1
            $stringbyline[0..$Startline], $stringbyline[$Endline..$TotalLines] | Out-String
        }
    }
}
function Convert-OGUserEvent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][PSObject]$Event,
        [Parameter(Mandatory = $false)][datetime]$CutOver
    )
    $Body = @{}
    if ($Event.subject) {
        $body.subject = $Event.subject
    }
    if ($Event.body.content) {
        $updateContent = Remove-OGTeamsEventInfo -html $Event.body.content
        $bodyContent = [PSCustomObject]@{
            contentType = "HTML"
            content     = $updateContent
        }
        $body.body = $bodycontent
    }
    if ($Event.start) {
        $start = [PSCustomObject]@{
            dateTime = $Event.start.dateTime
            timeZone = $Event.start.timeZone
        }
        $body.start = $start
    }
    if ($Event.end) {
        $end = [PSCustomObject]@{
            dateTime = $Event.end.dateTime
            timeZone = $Event.end.timeZone
        }
        $body.end = $end
    }
    if ($event.recurrence) {
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
        if ($CutOver) {
            [string]$CutOver = $CutOver.ToString("yyyy-MM-dd")
            $recurrence.range.startDate = $CutOver
        }
        if ($recurrence.range.type -ne "noEnd") {
            $recurrence.range | Add-Member -MemberType NoteProperty  -Name 'endDate' -Value $event.recurrence.range.endDate
        }
        $body.recurrence = $recurrence
    }
    if ($event.location.displayName) {
        $location = [PSCustomObject]@{
            displayName = $event.location.displayName
        }
        $body.location = $location
    }
    if ($event.attendees) {
        $array = @(
            foreach ($attendeeItem in $event.attendees) {
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
    if ($event.allowNewTimeProposals) {
        $allowNewTimeProposals = $event.allowNewTimeProposals
        $body.allowNewTimeProposals = $allowNewTimeProposals
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
