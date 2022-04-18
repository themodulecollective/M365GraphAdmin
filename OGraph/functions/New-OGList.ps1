Function New-OGList
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$SiteId,
        [Parameter(Mandatory)]$Name,
        [Parameter(Mandatory)][Array]$Columns
    )
    $NewListColumns = @(foreach ($Column in $Columns)
        {
            $item = [PSCustomObject]@{
                name = $Column
                text = [PSCustomObject]@{}
            }
            $item
        })
    $NewListBody = [PSCustomObject]@{
        displayName = $Name
        columns     = $NewListColumns
        list        = [PSCustomObject]@{
            template = 'genericList'
        }
    }
    $account_params = @{
        Headers     = @{Authorization = "Bearer $($GraphAPIKey)" }
        Uri         = "https://graph.microsoft.com/$GraphVersion/sites/$SiteId/lists"
        Body        = $NewListBody | ConvertTo-Json -Depth 3
        Method      = 'POST'
        ContentType = 'application/json'
    }
    Invoke-RestMethod @Account_params

}

