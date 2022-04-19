Function Get-OGGroupMember
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ObjectId
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$ObjectId/members"
    Get-OGNextPage -uri $URI

}

