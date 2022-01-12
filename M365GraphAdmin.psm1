# Sections:
# Helper Functions - Not for inclusion in User Import
# Access Tokens
# AzureAD Administration
# Users
# Licenses
# Groups
# Mail
# SharePoint Online
# Here Be the Dragons of SPO

# Notes: ToDo items are placed hierarchically. Examples: ToDos for the entire module, place at top. ToDo for a Section, place at top of section. ToDo for a specific function, place within function at top.

# Discuss Module dependency for MSAL.PS. Get-MSALTOKEN

# DEFAULT GRAPH VERSION

$Script:GraphVersion = "v1.0"

# HELPER FUNCTIONS

function Get-NextPage {
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
        Get-NextPage -Uri $results."@odata.nextlink"
    }
    elseif (!$results."@odata.nextlink") {
        $Result.Value
    }
}

# ACCESS TOKENS
## ToDo: Function to trigger Auth flow to existing module with application permissions for functions in this module
## ToDo: Combine all into single function Get-GraphAccessToken?

function Set-GraphVersion {
    [CmdletBinding(DefaultParameterSetName = 'v1')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Beta')][switch]$Beta,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'v1')][switch]$v1
    )
    if ($v1) {
        $Script:GraphVersion = "v1.0"
    } 
    if ($Beta) {
        $Script:GraphVersion = "beta"
    }   
}
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
function Get-GraphAPIKey {
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
function Connect-HGMsolService {
    ## todo: add token refresh
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
function Consent-HGMsolService {
    ## todo: add administrator consent flow
    ## todo: add token refresh
    start "https://login.microsoftonline.com/common/adminconsent?client_id=f6557fc2-d4a5-4266-8f4c-2bdcd0cd9a2d"
}
# AZUREAD ADMINISTRATION
# Users
function Get-GraphUser {
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
        Get-NextPage -uri $URI -SearchDisplayName
    }
    if ($All) {
        $URI = "https://graph.microsoft.com/$GraphVersion/users"
        Get-NextPage -Uri $URI
    }   
}
function Set-GraphUser {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$UserPrincipalName,
        [Parameter(Mandatory = $false)][String]$NewUserPrincipalName,
        [Parameter(Mandatory = $false)][String]$accountEnabled,
        [Parameter(Mandatory = $false)][String]$FirstName,
        [Parameter(Mandatory = $false)][String]$LastName,
        [Parameter(Mandatory = $false)][String]$DisplayName
    )
    $User = Get-GraphUser -UserPrincipalName $UserPrincipalName
    $bodyparams = @{}
    if ($NewUserPrincipalName) {
        $bodyparams.add("userPrincipalName", $NewUserPrincipalName)
    }
    if ($accountEnabled) {
        $bodyparams.add("accountEnabled", $accountEnabled)
    }
    if ($FirstName) {
        $bodyparams.add("givenName", $FirstName)
    }
    if ($LastName) {
        $bodyparams.add("surname", $LastName)
    }
    if ($DisplayName) {
        $bodyparams.add("displayName", $DisplayName)
    }
    $Body = [PSCustomObject]@{}
    $body | Add-Member $bodyparams
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$($User.Id)"
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$($User.Id)?`$select=signInActivity"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @Account_params
    $response.signInActivity.lastsignindatetime
}
# Licenses
function Get-GraphUserSkus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    $user = get-graphuser -UserPrincipalName $UserPrincipalName
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/Users/$($user.Id)/licenseDetails"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value | select skuPartNumber, skuid
}
function Get-GraphSkus {
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/subscribedSkus"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value | select consumedUnits, skuId, skuPartNumber, prepaidunits
}
# Groups
## ToDo: Add Set-GraphGroup
function Get-GraphGroup {
    [CmdletBinding(DefaultParameterSetName = 'OID')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'OID')]$ObjectID,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Search')]$SearchDisplayName,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'All')][Switch]$All
    )
    if ($ObjectID) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            URI         = "https://graph.microsoft.com/$GraphVersion/groups/$ObjectID"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($SearchDisplayName) {
        $URI = "https://graph.microsoft.com/$GraphVersion/groups?`$search=`"displayName:$SearchDisplayName`""
        Get-NextPage -uri $URI -SearchDisplayName
    }
    if ($All) {
        $URI = "https://graph.microsoft.com/$GraphVersion/groups"
        Get-NextPage -Uri $URI
    }   
}
function Get-GraphGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ObjectId
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$ObjectId/members"
    Get-NextPage -uri $URI
}
function Add-GraphGroupMember {
    ## ToDo: Test UserObjectID param
    [CmdletBinding(DefaultParameterSetName = 'UOID')]
    param (
        [Parameter(Mandatory,
        ParameterSetName = 'UOID')]
        [Parameter(ParameterSetName = 'UPN')]$GroupObjectID,
        [Parameter(Mandatory = $false,
        ParameterSetName = 'UPN')]$UserPrincipalName,
        [Parameter(Mandatory = $false,
        ParameterSetName = 'UOID')]$UserObjectID
    )
    if ($UserPrincipalName) {
        $UserObjectID = get-graphuser -UserPrincipalName $UserPrincipalName
    }
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$GroupObjectID/members/`$ref"
    $Body = [PSCustomObject]@{
        "@odata.id" = "https://graph.microsoft.com/$GraphVersion/directoryObjects/$($UserObjectID)"
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
    ## ToDo: Replace GroupID with ObjectId for consistency
    ## ToDo: Replace Member with UserPrincipalName
    ## ToDo: Add UserObjectID param    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$GroupID,
        [Parameter(Mandatory)]$Member
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$groupID/members/$Member/`$ref"
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = $URI
        Method      = 'DELETE'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}

# MAIL
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$UserID/sendMail"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params    
}

# SHAREPOINT ONLINE
## ToDo: Do we want to add in WebURL lookup in addtion to the current SiteID params?
function Get-GraphSite {
    ## ToDo: Check Graph for filter of personal sites in query instead of in PS
    ## ToDo: Fix usablilty language for params all and no personal sites. Setting -All and -NoPersonalSites currently runs All 2x. If no filtering in graph endpoint, then combine All and NoPersonalSites into same IF by adding IF.
    [CmdletBinding(DefaultParameterSetName = 'SID')]
    Param(
        [Parameter(Mandatory = $False,
            ParameterSetName = 'SID')]$SiteId,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'All')][Switch]$All,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'NoOD')][Switch]$AllNoPersonalSites
    )
    if ($PSBoundParameters.SiteId) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($All -and !$SiteId -and !$AllNoPersonalSites) {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/?$search=*"
        Get-NextPage -uri $URI
    }
    if ($AllNoPersonalSites -and !$all) {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/?$search=*"
        $all_results = Get-NextPage -uri $URI
        $all_results | Where-Object WebUrl -notlike "*/personal/*"
    }
}
function Get-GraphSitePermissions {
    ## ToDo: Review this function. I think its retrieving sharing permissions within the site, but I don't remember. Not even sure if it works.
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]$SiteId
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/permissions"
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
    $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists"
    Get-NextPage -uri $URI
}
function Get-GraphListItem {
    ## ToDo: Wrap in psobject to include weburl,createdby etc with fields
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory = $false)]$ItemId
    )
    if ($ItemId) {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items?expand=fields"
        $response = Get-NextPage -uri $URI | where id -eq $ItemId
        $response.fields
    }
    else {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items?expand=fields"
        $response = Get-NextPage -uri $URI
        $response.fields
    }
}

# HERE BE THE DRAGONS OF SPO
#Notes: These were written to solve the problem of exporting data in a headless Azure Automation script. Exportto-CSV isn't an option because you can't access the disk of the server after the session is closed. So i wanted "Exportto-SPOList". They work, but were created with the specific scripts i was writing in mind. As a result, they are not fully functional and need a hard review of what they actually do and how, BUT its really useful in certain situations. :)
function New-GraphList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory)][Array]$Columns
    )
    $NewListColumns = @(foreach ($Column in $Columns) {
            $item = [PSCustomObject]@{
                name = $Column
                text = [PSCustomObject]@{}
            }
            $item
        })
    $NewListBody = [PSCustomObject]@{
        displayName = $Name
        columns     = $NewListColumns
        list        = [PSCustomObject]@{
            template = 'genericList'
        }
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists"
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
    $URI = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/Columns"
    Get-NextPage -uri $URI
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/Columns"
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items"
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items/$ListItemId/fields"
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
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/items/$ListItem"
        Method      = 'DELETE'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params
}