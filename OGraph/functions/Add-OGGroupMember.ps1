<#
.SYNOPSIS
Add Group Member

.DESCRIPTION
Long description

.PARAMETER GroupObjectID
Parameter description

.PARAMETER UserPrincipalName
Parameter description

.PARAMETER UserObjectID
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Add-OGGroupMember {
    # ToDo: Test UserObjectID param
    [CmdletBinding(DefaultParameterSetName = 'UOID')]

    param (
        [Parameter(Mandatory,
            ParameterSetName = 'UOID')]
        [Parameter(ParameterSetName = 'UPN')]$GroupObjectID,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'UPN')]$UserPrincipalName,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'UOID')]$UserObjectID
    )
    if ($UserPrincipalName) {
        $UserObjectID = Get-OGUser -UserPrincipalName $UserPrincipalName
    }
    $URI = "https://graph.microsoft.com/$GraphVersion/groups/$GroupObjectID/members/`$ref"
    $Body = [PSCustomObject]@{
        '@odata.id' = "https://graph.microsoft.com/$GraphVersion/directoryObjects/$($UserObjectID.Id)"
    }
    $account_params = @{
        Headers = @{Authorization = "Bearer $Key" }
        Uri     = $URI
        Body    = $Body | ConvertTo-Json
        Method  = 'POST'
    }
    Invoke-GraphRequest @Account_params
}