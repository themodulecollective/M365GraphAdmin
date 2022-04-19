$ModuleFolder = Split-Path $PSCommandPath -Parent

$Scripts = Join-Path -Path $ModuleFolder -ChildPath 'scripts'
$Functions = Join-Path -Path $ModuleFolder -ChildPath 'functions'

Write-Information -MessageData "Scripts Path  = $Scripts" -InformationAction Continue
Write-Information -MessageData "Functions Path  = $Functions" -InformationAction Continue

$Script:ModuleFiles = @(
    $(Join-Path -Path $Scripts -ChildPath 'Initialize.ps1')
    # Load Functions
    $(Join-Path -Path $functions -ChildPath 'Add-OGGroupMember.ps1')
    $(Join-Path -Path $functions -ChildPath 'Connect-OGMsolService.ps1')
    $(Join-Path -Path $functions -ChildPath 'Consent-OGMsolService.ps1')
    $(Join-Path -Path $functions -ChildPath 'Convert-OGGroupEvent.ps1')
    $(Join-Path -Path $functions -ChildPath 'Convert-OGUserEvent.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGAPIKey.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGAzureKey.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGGroup.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGGroupEvents.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGGroupMember.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGList.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGListColumns.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGListItem.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGNextPage.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGSite.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGSitePermissions.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGSkus.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGUser.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGUserEvents.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGUserLastSignIn.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGUserSeriesInstance.ps1')
    $(Join-Path -Path $functions -ChildPath 'Get-OGUserSkus.ps1')
    $(Join-Path -Path $functions -ChildPath 'New-OGList.ps1')
    $(Join-Path -Path $functions -ChildPath 'New-OGListColumn.ps1')
    $(Join-Path -Path $functions -ChildPath 'New-OGListItem.ps1')
    $(Join-Path -Path $functions -ChildPath 'OldConvert-OGUserEvent.ps1')
    $(Join-Path -Path $functions -ChildPath 'Remove-OGGroupMember.ps1')
    $(Join-Path -Path $functions -ChildPath 'Remove-OGListItem.ps1')
    $(Join-Path -Path $functions -ChildPath 'Remove-OGTeamsEventInfo.ps1')
    $(Join-Path -Path $functions -ChildPath 'Send-OGMessage.ps1')
    $(Join-Path -Path $functions -ChildPath 'Set-OGUser.ps1')
    $(Join-Path -Path $functions -ChildPath 'Set-OGVersion.ps1')
    $(Join-Path -Path $functions -ChildPath 'Update-OGListItem.ps1')
    # Finalize / Run any Module Functions defined above
    $(Join-Path -Path $Scripts -ChildPath 'RunFunctions.ps1')
)

Write-Information -MessageData $($ModuleFiles -join ';') -InformationAction Continue

foreach ($f in $ModuleFiles)
{
    . $f
}