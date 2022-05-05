<#
    .SYNOPSIS
    Provide paginiation functionality on all functions
    
    .DESCRIPTION
    Long description
    
    .PARAMETER URI
    URI passed from parent function
    example: get-oguser would pass https://graph.microsoft.com/$GraphVersion/users
    
    .PARAMETER SearchDisplayName
    Allows additional header information for search functionality on some parent functions
    
    .PARAMETER PSObject
    Outputs response as PSobject instead of HashTable

    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
Function Get-OGNextPage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$URI,
        [Switch]$SearchDisplayName
    )
    $account_params = @{
        Headers     = @{Authorization = "Bearer $Key" }
        URI         = $URI
        Method      = 'GET'
        OutputType  = 'PSObject'
    }
    if ($SearchDisplayName) {
        $account_params.headers.add('ConsistencyLevel', 'eventual')
    }
    $Result = Invoke-GraphRequest @Account_params
    if ($results.'@odata.nextlink') {
        Get-OGNextPage -Uri $results.'@odata.nextlink'
    }
    elseif (!$results.'@odata.nextlink') {
        $Result.Value
    }
}