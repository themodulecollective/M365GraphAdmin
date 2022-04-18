Function Get-OGSite
{
    
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
    if ($PSBoundParameters.SiteId)
    {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
            Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId"
            Method      = 'GET'
            ContentType = 'application/json'
        }
        Invoke-RestMethod @Account_params
    }
    if ($All -and !$SiteId -and !$AllNoPersonalSites)
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/?$search=*"
        Get-OGNextPage -uri $URI
    }
    if ($AllNoPersonalSites -and !$all)
    {
        $URI = "https://graph.microsoft.com/$GraphVersion/sites/?$search=*"
        $all_results = Get-OGNextPage -uri $URI
        $all_results | Where-Object WebUrl -NotLike '*/personal/*'
    }

}

