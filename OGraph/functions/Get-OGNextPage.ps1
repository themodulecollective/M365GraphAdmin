Function Get-OGNextPage {
    
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
        $account_params.headers.add('ConsistencyLevel', 'eventual')
    }
    $Result = Invoke-RestMethod @Account_params
    if ($result.'@odata.nextlink') {
        Get-OGNextPage -Uri $result.'@odata.nextlink'
    }
    elseif (!$result.'@odata.nextlink') {
        $Result.Value
    }

}

        [Parameter(Mandatory = $True)][string]$URI,
        [Switch]$SearchDisplayName
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $Key" }
        URI         = $URI
        Method      = 'GET'
        OutputType  = 'PSObject'
    }
    if ($SearchDisplayName) {
        $account_params.headers.add('ConsistencyLevel', 'eventual')
    }
    $Result = Invoke-GraphRequest @Account_params
    if ($result.'@odata.nextlink') {
        Get-OGNextPage -Uri $result.'@odata.nextlink'
    }
    elseif (!$result.'@odata.nextlink') {
        $Result.Value
    }
}