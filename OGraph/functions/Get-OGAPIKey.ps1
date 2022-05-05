<#
.SYNOPSIS
Get API Token from Azure AD app

.DESCRIPTION
Long description

.PARAMETER ApplicationID
Parameter description

.PARAMETER TenantId
Parameter description

.PARAMETER AccessSecret
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-OGAPIKey
{
    
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