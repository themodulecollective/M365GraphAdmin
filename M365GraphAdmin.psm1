#Notes: ToDo items are placed hierarchically. Examples: ToDos for the entire module, place at top. ToDo for a Section, place at top of section. ToDo for a specific function, place within function at top.

## ToDo: Discuss Current Use of Graph Beta vs v1.0

# Access Tokens
## ToDo: Function to trigger Auth flow to existing module with application permissions for functions in this module
function Get-GraphAzureKey {

    $ClientID = '1950a258-227b-4e31-a9cf-717495945fc2'
    $TenantID = 'common'
    $Resource = "https://graph.microsoft.com/"
    
    $DeviceCodeRequestParams = @{
        Method = 'POST'
        Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/devicecode"
        Body   = @{
            client_id = $ClientId
            resource  = $Resource
        }
    }
    
    $DeviceCodeRequest = Invoke-RestMethod @DeviceCodeRequestParams
    Write-Host $DeviceCodeRequest.message -ForegroundColor Yellow
    Read-Host -Prompt "Press any key to continue"

    $TokenRequestParams = @{
        Method = 'POST'
        Uri    = "https://login.microsoftonline.com/$TenantId/oauth2/token"
        Body   = @{
            grant_type = "urn:ietf:params:oauth:grant-type:device_code"
            code       = $DeviceCodeRequest.device_code
            client_id  = $ClientId
        }
    }
    $TokenRequest = Invoke-RestMethod @TokenRequestParams
    $Script:GraphAPIKey = $TokenRequest.access_token
}
function Get-GraphAPIKey{
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

# AzureAD Administration
function Get-GraphUser {
## ToDo: Validate SearchString param. Possibly only searching DisplayName.
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False)]$UserPrincipalName,
        [Parameter(Mandatory=$False)]$SearchString,
        [Switch]$All
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Method      = 'GET'
        ContentType = 'application/json'
    }
    if ($All) {
        $URI = "https://graph.microsoft.com/beta/users"
        $account_params.add("URI","$URI")
        $all_results = @()
        $Results = Invoke-RestMethod @Account_params
        $all_results += $Results.value
        while ($null -ne $results."@odata.nextlink") {
            $account_params = @{
                Headers     = @{Authorization = "Bearer $($GraphAPIKey)"}
                Uri         = $results."@odata.nextlink"
                Method      = 'GET'
                ContentType = 'application/json'
            }
            $Results = Invoke-RestMethod @Account_params
            $all_results += $Results.value
        }   
        $all_results
    }
    if($UserPrincipalName) {
       $URI = "https://graph.microsoft.com/beta/users/$userprincipalname"
       $account_params.add("URI","$URI")
       Invoke-RestMethod @Account_params
    }
    if ($SearchString) {
        $URI = "https://graph.microsoft.com/beta/users?`$search=`"displayName:$SearchString`""
        $account_params.add("URI","$URI")
        $account_params.headers.add("ConsistencyLevel","eventual")
        $results = Invoke-RestMethod @Account_params
        $results.value
    }
}
function Set-GraphUser {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$UserPrincipalName,
        [Parameter(Mandatory=$false)][String]$NewUserPrincipalName,
        [Parameter(Mandatory=$false)][String]$accountEnabled,
        [Parameter(Mandatory=$false)][String]$FirstName,
        [Parameter(Mandatory=$false)][String]$LastName,
        [Parameter(Mandatory=$false)][String]$DisplayName
        )
    $User = Get-GraphUser -UserPrincipalName $UserPrincipalName
    $bodyparams = @{}
    if ($NewUserPrincipalName) {
        $bodyparams.add("userPrincipalName",$NewUserPrincipalName)
        }
    if ($accountEnabled) {
       $bodyparams.add("accountEnabled",$accountEnabled)
        }
    if ($FirstName) {
        $bodyparams.add("givenName",$FirstName)
    }
    if ($LastName) {
        $bodyparams.add("surname",$LastName)
    }
    if ($DisplayName) {
        $bodyparams.add("displayName",$DisplayName)
    }
    $Body = [PSCustomObject]@{}
    $body | Add-Member $bodyparams
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/users/$($User.Id)"
        body        = $body | ConvertTo-Json -Depth 5
        Method      = 'PATCH'
        ContentType = 'application/json'
    }
    $quietrun = Invoke-RestMethod @Account_params
}
function Get-GraphUserLastSignIn {
## ToDo: Review where the data is being pulled from. Signin date seems old
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    $User = get-graphuser -UserPrincipalName $UserPrincipalName
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/users/$($User.Id)?`$select=signInActivity"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @Account_params
    $response.signInActivity.lastsignindatetime
}
function Get-GraphUserSkus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    $user = get-graphuser -UserPrincipalName $UserPrincipalName
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/Users/$($user.Id)/licenseDetails"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value | select skuPartNumber,skuid
}
function Get-GraphSkus {
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/subscribedSkus"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value | select consumedUnits,skuId,skuPartNumber,prepaidunits
}
# Groups
## ToDo: Add Set-GraphGroup?
function Get-GraphGroup {
## ToDo: Clean up, add -all for consisency, add objectid, SearchString is searching DisplayName
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]$SearchString
    )
    $all_results = @()
    $URI = "https://graph.microsoft.com/beta/groups"
    $account_params = @{
        Headers     = @{
            Authorization = "Bearer $($GraphAPIKey)"
        }
        Uri         = $URI
        Method      = 'GET'
        ContentType = 'application/json'
    }
    if ($SearchString) {
        $account_params.URI = "$URI`?`$search=`"displayName:$SearchString`""
        $account_params.headers.add("ConsistencyLevel","eventual")
    }
    $Results =Invoke-RestMethod @Account_params
    $all_results += $Results.value
    while ($null -ne $results."@odata.nextlink") {
        $account_params = @{
            Headers     = @{
                Authorization = "Bearer $($GraphAPIKey)"
            }
            Uri         = $results."@odata.nextlink"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $Results = Invoke-RestMethod @Account_params
        $all_results += $Results.value
    }   
    $all_results
}
function Get-GraphGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ObjectId
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/groups/$ObjectId/members"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $all_results = @()
    $all_results += $Results.value
    while ($null -ne $results."@odata.nextlink") {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = $results."@odata.nextlink"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $Results = Invoke-RestMethod @Account_params
        $all_results += $Results.value
    }
    $all_results
}
function Add-GraphGroupMember {
## ToDo Replace GroupID with ObjectId for consistency. Replace Member with UserPrincipalName. Add UserObjectID param
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$GroupID,
        [Parameter(Mandatory)]$Member
    )
    $Member = get-graphuser -UserPrincipalName $Member
    $URI = "https://graph.microsoft.com/beta/groups/$groupID/members/`$ref"
    $Body = [PSCustomObject]@{
        "@odata.id" = "https://graph.microsoft.com/beta/directoryObjects/$($Member.id)"
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = $URI
        Body        = $Body | ConvertTo-Json
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}
function Remove-GraphGroupMember {
## ToDo Replace GroupID with ObjectId for consistency. Replace Member with UserPrincipalName. Add UserObjectID param
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$GroupID,
        [Parameter(Mandatory)]$Member
    )
    $URI = "https://graph.microsoft.com/beta/groups/$groupID/members/$Member/`$ref"
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = $URI
        Method      = 'DELETE'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}

# Mail
## ToDo: Discuss inclusion in module. Its cool, but dangerous. Allows user to send as any user in the tenant. Originally used it to replace Send-Mailmessage since its now considered insecure. The URI can be updated to for "me" instead of setting the SenderID, but if the App registration is using Application perms instead of delegated, I think that will fail.
function Send-GraphMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$Message,
        [Parameter(Mandatory)]$Subject,
        [Parameter(Mandatory)]$Recipient,
        [Parameter(Mandatory)]$SenderID,
        [Parameter(Mandatory = $false)]$Cc
    )
    $Body = [PSCustomObject]@{
        message         = [PSCustomObject]@{
            subject      = $Subject
            body         = [PSCustomObject]@{
                contentType = "Text"
                content     = $Message
            }
            toRecipients = @(
                [PSCustomObject]@{
                    emailAddress = [PSCustomObject]@{
                        address = $Recipient
                    }
                }
            )
        }
        saveToSentItems = "true"
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/users/$UserID/sendMail"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params    
}

# SharePoint Online
## ToDo: Do we want to add in WebURL lookup in addtion to the current SiteID params?
function Get-GraphSite {
## ToDo: Check Graph for filter of personal sites in query instead of in PS. Fix usablilty language for params all and no personal sites. Setting -All and -NoPersonalSites currently runs All 2x. If no filtering in graph endpoint, then combine All and NoPersonalSites into same IF by adding IF.
    [CmdletBinding(DefaultParameterSetName = 'SID')]
    Param(
        [Parameter(Mandatory = $False,
            ParameterSetName = 'SID')]$SiteId,
        [Switch]$All,
        [Parameter(Mandatory = $False,
        ParameterSetName = 'NoOneDrive')]$NoPersonalSites
    )
    if ($PSBoundParameters.SiteId) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/beta/sites/$SiteId"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($All -and !$SiteId) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/beta/sites/?$search="
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $all_results = @()
        $Results = Invoke-RestMethod @Account_params
        $all_results += $Results.value
        while ($null -ne $results."@odata.nextlink") {
            $account_params = @{
                Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
                Uri         = $results."@odata.nextlink"
                Method      = 'GET'
                ContentType = 'application/json'
            }
            $Results = Invoke-RestMethod @Account_params
            $all_results += $Results.value
        }
        $all_results
    }
    if ($NoPersonalSites){
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/beta/sites/?$search="
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $all_results = @()
        $Results = Invoke-RestMethod @Account_params
        $all_results += $Results.value
        while ($null -ne $results."@odata.nextlink") {
            $account_params = @{
                Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
                Uri         = $results."@odata.nextlink"
                Method      = 'GET'
                ContentType = 'application/json'
            }
            $Results = Invoke-RestMethod @Account_params
            $all_results += $Results.value
        }
        $all_results | Where-Object WebUrl -notlike "*/personal/*"
    }
}
function Get-GraphSitePermissions {
## ToDo: review this function. I think its retrieving sharing permissions within the site, but I don't remember. Not even sure if it works.
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]$SiteId
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/permissions"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value
}
function Get-GraphList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value
}
function Get-GraphListItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory = $false)]$ItemId
    )
    if ($ItemId) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/items/$ItemId"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $response = Invoke-RestMethod @Account_params
        $response.fields
    }
    else {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/items?expand=fields"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        $response = Invoke-RestMethod @Account_params
        $response.value.fields
    }
}

# HERE BE DRAGONS
#Notes: These were written to solve the problem of exporting data in a headless Azure Automation script. Exportto-CSV isn't an option because you can't access the disk of the server after the session is closed. So i wanted "Exportto-SPOList". They work, but were created with the specific scripts i was writing in mind. As a result, they are not fully functional and need a hard review of what they actually do and how, BUT its really useful in certain situations. :)
function New-GraphList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory)][Array]$Columns
    )
    $NewListColumns = @()
    foreach ($Column in $Columns) {
        $item = [PSCustomObject]@{
            name = $Column
            text = [PSCustomObject]@{}
        }
        $NewListColumns += $item
    }
    $NewListBody = [PSCustomObject]@{
        displayName = $Name
        columns     = $NewListColumns
        list        = [PSCustomObject]@{
            template = 'genericList'
        }
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists"
        Body        = $NewListBody | ConvertTo-Json -Depth 3
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}
function Get-GraphListColumns {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/Columns"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value
}
function New-GraphListColumn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory = $false)]$Description
    )
    if (!$Description) {
        $Body = [PSCustomObject]@{
            description         = [PSCustomObject]@{}
            enforceUniqueValues = $false
            hidden              = $false
            indexed             = $false
            name                = $Name
            text                = [PSCustomObject]@{
                allowMultipleLines          = $false
                appendChangesToExistingText = $false
                linesForEditing             = 0
                maxLength                   = 225
            }
        }
    }
    else {
        $Body = [PSCustomObject]@{
            description         = $Description
            enforceUniqueValues = $false
            hidden              = $false
            indexed             = $false
            name                = $Name
            text                = [PSCustomObject]@{
                allowMultipleLines          = $false
                appendChangesToExistingText = $false
                linesForEditing             = 0
                maxLength                   = 225
            }
        }
    }

    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/Columns"
        Body        = $Body | ConvertTo-Json -Depth 4
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}
function New-GraphListItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$ListItem
    )
    $ListItemBody = [PSCustomObject]@{
        fields = $ListItem
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/items"
        Body        = $ListItemBody | ConvertTo-Json -Depth 3
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}
function Update-GraphListItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$ListItemId,
        [Parameter(Mandatory)]$ItemUpdates
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/items/$ListItemId/fields"
        Body        = $ItemUpdates | ConvertTo-Json -Depth 5
        Method      = 'PATCH'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
   # $ItemUpdates | ConvertTo-Json -Depth 5
}
function Remove-GraphListItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$ListItem
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/beta/sites/$SiteId/lists/$ListId/items/$ListItem"
        Method      = 'DELETE'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}