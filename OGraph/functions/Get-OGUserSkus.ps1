Function Get-OGUserSkus
{
    
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
    $Results.value | Select-Object skuPartNumber, skuid

}

