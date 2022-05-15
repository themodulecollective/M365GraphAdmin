Function Get-OGUserDrive {
    
    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param (
        [Parameter(Mandatory = $False,
            ParameterSetName = 'UPN')]$UserPrincipalName
    )
    if ($UserPrincipalName) {
        $account_params = @{
            Headers     = @{Authorization = "Bearer $Key" }
            URI         = "/$GraphVersion/users/$userprincipalname/Drive"
            Method      = 'GET'
            OutputType  = 'PSObject'
            ContentType = 'application/json'
        }
        Invoke-GraphRequest @Account_params
    }
}