function Get-OGUserDriveValidation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False, ParameterSetName = 'multiUser')][psobject[]]
        $SourceData,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName, ParameterSetName = 'singleUser')][string]
        $UserPrincipalName,
        [Parameter(Mandatory = $false, ParameterSetName = 'multiUser')][string]
        $UPNHeader,
        [Parameter(Mandatory, ParameterSetName = 'multiUser')]
        [Parameter(Mandatory, ParameterSetName = 'singleUser')]
        $TenantName,
        [Parameter(Mandatory = $false)]$ExportPath,
        [Parameter(Mandatory, ParameterSetName = 'multiUser')][Int]$ValidationLimit,
        [Switch]$PnPPowershell
        
    )
        
    begin {
        $TenantName = $TenantName.tolower()
        $TenantURL = "https://$($tenantName)-my.sharepoint.com/personal/*"
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
                        $target = $target.personalurl
                    }
                    else {
                        $target = Get-OGUserDrive -UserPrincipalName $item.$UPNHeader
                        $target = $target.weburl
                    }
                    if ($target -like $TenantURL) {
                        $_ | Select-Object *, @{Name = 'targetODurl'; Expression = { $target } }
                    }
                    else {
                        $_ | Select-Object *, @{Name = 'targetODurl'; Expression = { $null } }
                    }
                    $target = $null
                })
        }
        else {
            $target = Get-OGUserDrive -UserPrincipalName $UserPrincipalName
            if ($target.weburl -like $TenantURL) {
                $target | select-object weburl
            }
            else {
                Write-Information -messagedata "No Personal Site" -InformationAction Continue
            }
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