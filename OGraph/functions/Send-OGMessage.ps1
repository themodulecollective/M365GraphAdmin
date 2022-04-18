Function Send-OGMessage
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$Message,
        [Parameter(Mandatory)]$Subject,
        [Parameter(Mandatory)]$Recipient,
        [Parameter(Mandatory)]$SenderID,
        [Parameter(Mandatory = $false)]$Cc
    )
    $Body = [PSCustomObject]@{
        message         = [PSCustomObject]@{
            subject      = $Subject
            body         = [PSCustomObject]@{
                contentType = 'Text'
                content     = $Message
            }
            toRecipients = @(
                [PSCustomObject]@{
                    emailAddress = [PSCustomObject]@{
                        address = $Recipient
                    }
                }
            )
        }
        saveToSentItems = 'true'
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$UserID/sendMail"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

