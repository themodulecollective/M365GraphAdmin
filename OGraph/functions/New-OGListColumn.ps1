Function New-OGListColumn
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$ListId,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory = $false)]$Description
    )
    if (!$Description)
    {
        $Body = [PSCustomObject]@{
            description         = [PSCustomObject]@{}
            enforceUniqueValues = $false
            hidden              = $false
            indexed             = $false
            name                = $Name
            text                = [PSCustomObject]@{
                allowMultipleLines          = $false
                appendChangesToExistingText = $false
                linesForEditing             = 0
                maxLength                   = 225
            }
        }
    }
    else
    {
        $Body = [PSCustomObject]@{
            description         = $Description
            enforceUniqueValues = $false
            hidden              = $false
            indexed             = $false
            name                = $Name
            text                = [PSCustomObject]@{
                allowMultipleLines          = $false
                appendChangesToExistingText = $false
                linesForEditing             = 0
                maxLength                   = 225
            }
        }
    }

    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists/$ListId/Columns"
        Body        = $Body | ConvertTo-Json -Depth 4
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

