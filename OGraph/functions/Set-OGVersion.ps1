Function Set-OGVersion
{
    
    [CmdletBinding(DefaultParameterSetName = 'v1')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Beta')][switch]$Beta,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'v1')][switch]$v1
    )
    if ($v1)
    {
        $Script:GraphVersion = 'v1.0'
    }
    if ($Beta)
    {
        $Script:GraphVersion = 'beta'
    }

}

