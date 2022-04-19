Function Connect-OGMsolService
{
    
    ## todo: add token refresh
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ApplicationID,
        [Parameter(Mandatory)]$TenantId,
        [Parameter(Mandatory)]$AccessSecret
    )
    $Body = @{
        Grant_Type    = 'client_credentials'
        Scope         = 'https://graph.microsoft.com/.default'
        client_Id     = $ApplicationID
        Client_Secret = $AccessSecret
    }
    $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $Body
    $Script:GraphAPIKey = $ConnectGraph.access_token

}

