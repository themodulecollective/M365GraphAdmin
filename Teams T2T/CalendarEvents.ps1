# Old Tenant Users
$OldTenantId = 'xxxxxxxxxxxxx'
$OldClientID = 'xxxxxxxxxxxxx'
$OldClientSecret = "xxxxxxxxxxxxx"
Get-GraphAPIKey -TenantId $OldTenantId -ApplicationID $OldClientID -AccessSecret $OldClientSecret
$UsersOldTenant = Get-GraphUser -All
# New Tenant Users
$NewTenantId = 'xxxxxxxxxxxxx'
$NewClientID = 'xxxxxxxxxxxxx'
$NewClientSecret = "xxxxxxxxxxxxx"
Get-GraphAPIKey -TenantId $NewTenantId -ApplicationID $NewClientID -AccessSecret $NewClientSecret
$UsersNewTenant = Get-GraphUser -All
$date = Get-Date
foreach ($UserNewTenant in $UsersNewTenant) {
    #$Events = Get-GraphUserEvents | Where-Object {$_.type -eq "SeriesMaster"} | Where-Object {$_.start.datetime -gt $date}

}
Get-GraphUserEvents  -UserPrincipalName DiegoS@wirelessoneonline.onmicrosoft.com -Filter "type eq singleInstance"
 and start gt 2017-04-01"