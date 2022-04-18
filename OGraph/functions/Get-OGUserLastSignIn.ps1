Function Get-OGUserLastSignIn
{
    
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

