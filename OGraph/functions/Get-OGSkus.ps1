Function Get-OGSkus
{
    
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/subscribedSkus"
        Method      = 'GET'
        ContentType = 'application/json'
    }
    $Results = Invoke-RestMethod @Account_params
    $Results.value | Select-Object consumedUnits, skuId, skuPartNumber, prepaidunits

}

