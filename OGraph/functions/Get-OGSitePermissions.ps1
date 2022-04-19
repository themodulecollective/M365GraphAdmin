Function Get-OGSitePermissions
{
    
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

