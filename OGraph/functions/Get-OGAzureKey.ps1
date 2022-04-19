Function Get-OGAzureKey
{
    

    $ClientID = '1950a258-227b-4e31-a9cf-717495945fc2'
    $TenantID = 'common'
    $Resource = 'https://graph.microsoft.com/'

    $DeviceCodeRequestParams = @{
        Method = 'POST'
        Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/devicecode"
        Body   = @{
            client_id = $ClientId
            resource  = $Resource
        }
    }

    $DeviceCodeRequest = Invoke-RestMethod @DeviceCodeRequestParams
    Write-Host $DeviceCodeRequest.message -ForegroundColor Yellow
    Read-Host -Prompt 'Press any key to continue'

    $TokenRequestParams = @{
        Method = 'POST'
        Uri    = "https://login.microsoftonline.com/$TenantId/oauth2/token"
        Body   = @{
            grant_type = 'urn:ietf:params:oauth:grant-type:device_code'
            code       = $DeviceCodeRequest.device_code
            client_id  = $ClientId
        }
    }
    $TokenRequest = Invoke-RestMethod @TokenRequestParams
    $Script:GraphAPIKey = $TokenRequest.access_token

}

