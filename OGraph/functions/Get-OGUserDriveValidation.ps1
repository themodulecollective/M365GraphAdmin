function Get-OGUserDriveValidation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False, ParameterSetName = 'multiUser')]
        $SourceData,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName, ParameterSetName = 'singleUser')]
        $UserPrincipalName,
        [Parameter(Mandatory = $false, ParameterSetName = 'multiUser')]
        $UPNHeader,
        [Parameter(Mandatory, ParameterSetName = 'multiUser')]
        [Parameter(Mandatory, ParameterSetName = 'singleUser')]
        $TenantName,
        [Parameter(Mandatory = $false)]$ExportPath,
        [Parameter(Mandatory, ParameterSetName = 'multiUser')][Switch]$ValidateFirstTen,
        [Switch]$PnPPowershell
        
    )
        
    begin {
        $TenantName = $TenantName.tolower()
        $TenantURL = "https://$($tenantName)-my.sharepoint.com/personal/*"
        if ($ValidateFirstTen) {
            $firstTen = 0..9
        }
        else {
            $firstTen = 0..($SourceData.length)
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'multiUser') {
            $results = @($SourceData[$firstTen].foreach({
                        if ($PnPPowershell) {
                            $target = Get-PnPUserProfileProperty -Account $psitem.$UPNHeader
                            $target = $target.personalurl
                        }
                        else {
                            $target = Get-OGUserDrive -UserPrincipalName $psitem.$UPNHeader
                            $target = $target.weburl
                        }
                        if ($target -like $TenantURL) {
                            $_ | Select-Object *, @{Name = 'targetODurl'; Expression = { $target } }
                        }
                        else {
                            $_ | Select-Object *, @{Name = 'targetODurl'; Expression = { $null } }
                        }
                        $target = $null
                    }))
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