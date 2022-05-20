function Get-OGUserDriveValidation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False, ParameterSetName = 'multiUser')][psobject[]]
        $SourceData,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName, ParameterSetName = 'singleUser')][string]
        $UserPrincipalName,
        [Parameter(Mandatory, ParameterSetName = 'multiUser')][Int]$ValidationLimit,
        [Switch]$PnPPowershell
    )
        
    begin {
        switch ($PSBoundParameters.Keys -contains 'ValidationLimit') {
            $true {
                $limit = $ValidationLimit - 1
                $SourceData = $SourceData[0..$limit]
            }
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'multiUser') {
            $results = @(foreach ($item in $SourceData) {
                    if ($PnPPowershell) {
                        $target = Get-PnPUserProfileProperty -Account $item.$UPNHeader
                    }
                    else {
                        $target = Get-OGUserDrive -UserPrincipalName $item.$UPNHeader

                    })
            }
            else {
                $target = Get-OGUserDrive -UserPrincipalName $UserPrincipalName

            }

        }
        end {
            if ($ExportPath) {
                $results | export-csv -Path $ExportPath
            }
            else {
                $results
            }
        }
    }