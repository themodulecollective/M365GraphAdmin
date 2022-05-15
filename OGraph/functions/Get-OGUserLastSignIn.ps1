Function Get-OGUserLastSignIn {
    
    ## ToDo: Review where the data is being pulled from. Signin date seems old
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$UserPrincipalName
    )
    $User = get-oguser -UserPrincipalName $UserPrincipalName
    $account_params = @{
        Uri    = "https://graph.microsoft.com/$GraphVersion/users/$($User.Id)?`$select=signInActivity"
        Method = 'GET'
    }
    $response = Invoke-GraphRequest @Account_params
    $response.signInActivity.lastsignindatetime
}

