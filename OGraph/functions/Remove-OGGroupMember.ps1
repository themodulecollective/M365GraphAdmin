<#
.SYNOPSIS
Remove member from Azure AD group membership

.DESCRIPTION
Long description

.PARAMETER ObjectId
Id of the groupt to remove the user from

.PARAMETER MemberId
Id of the user

.EXAMPLE
An example

.NOTES
General notes
#>
Function Remove-OGGroupMember {
    ## ToDo: Add UPN Functionality?
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$ObjectId,
        [Parameter(Mandatory)]$MemberId
    )
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$ObjectId/members/$MemberId/`$ref"
    $account_params = @{
        Headers = @{Authorization = "Bearer $Key" }
        Uri     = $URI
        Method  = 'DELETE'
    }
    Invoke-GraphRequest @Account_params
}