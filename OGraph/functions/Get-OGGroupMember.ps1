<#
.SYNOPSIS
Get Members of a Group in Azure AD

.DESCRIPTION
Long description

.PARAMETER ObjectId
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-OGGroupMember
{
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ObjectId
    )
    $URI = "/$GraphVersion/groups/$ObjectId/members"
    Get-OGNextPage -uri $URI

}