# currently broken. No sure why yet.
Function Send-OGMessage
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$Message,
        [Parameter(Mandatory)]$Subject,
        [Parameter(Mandatory)]$Recipient,
        [Parameter(Mandatory)]$SenderID
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
        Headers     = @{Authorization = "Bearer $Key" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/users/$UserID/sendMail"
        body        = $Body | ConvertTo-Json -Depth 10
        Method      = 'POST'
    }
    Invoke-GraphRequest @Account_params
}

