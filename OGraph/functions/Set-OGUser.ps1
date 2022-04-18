Function Set-OGUser
{
    
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
    if ($NewUserPrincipalName)
    {
        $bodyparams.add('userPrincipalName', $NewUserPrincipalName)
    }
    if ($accountEnabled)
    {
        $bodyparams.add('accountEnabled', $accountEnabled)
    }
    if ($FirstName)
    {
        $bodyparams.add('givenName', $FirstName)
    }
    if ($LastName)
    {
        $bodyparams.add('surname', $LastName)
    }
    if ($DisplayName)
    {
        $bodyparams.add('displayName', $DisplayName)
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

