Write-Output "[1/6] Connecting to Microsoft Graph via Managed Identity…"
Connect-MgGraph -Identity -NoWelcome

Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/organization" | Out-Null

Write-Output "[1/6]  Connected to Microsoft Graph"

Write-Output "[2/6] Connecting to SharePoint Online via Managed Identity…"

Connect-PnPOnline -Url "https://<YourSharePointSite>.sharepoint.com/sites/<YourSiteName>" -ManagedIdentity
$sharePointFolder = "Shared Documents/Reporting/Intune"
# $timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$fileName = "Devices_Report.csv"
$localPath = "$fileName"
Write-Output "[2/6]  Connected to SharePoint"

# ==============================
# 2. Helper – Graph Batch Engine
# ==============================

function Invoke-GraphBatch {
    param (
        [Parameter(Mandatory)] $Requests,
        [ValidateSet('beta','v1.0')]$ApiVersion = 'beta',
        [int]$BatchSize = 20
    )

    $bodies   = [System.Collections.Generic.List[object]]::new()
    $responses = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

    for ($i = 0; $i -lt $Requests.Count; $i += $BatchSize) {
        $end = [Math]::Min($i + $BatchSize - 1, $Requests.Count - 1)
        $bodies.Add(@{
            Method      = 'POST'
            Uri         = "https://graph.microsoft.com/$ApiVersion/`$batch"
            ContentType = 'application/json'
            Body        = @{ requests = @($Requests[$i..$end]) } | ConvertTo-Json -Depth 5
        })
    }

    foreach ($body in $bodies) {
        $result = Invoke-MgGraphRequest @body
        foreach ($r in $result.responses) {
            $responses.Add([pscustomobject]@{
                id      = $r.id
                body    = $r.body
                error   = $r.error
            })
        }
    }
    return $responses
}

# =====================================
# 3. Pull basic list of managed devices
# =====================================

Write-Output "[3/6] Retrieving managed devices list (ID + Name)…"
$baseUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$select=id,deviceName"
$devices  = @()
$nextLink = $baseUri

while ($nextLink) {
    $page      = Invoke-MgGraphRequest -Method GET -Uri $nextLink -OutputType PSObject
    $devices  += $page.value
    $nextLink  = $page.'@odata.nextLink'
}

Write-Output "        → Devices found: $($devices.Count)"

# ============================================================
# 4. Build and send batch requests for detailed device objects
#    + usersLoggedOn and deviceActionResults are NOT returned by
#      default – we need the full object per device.
# ============================================================

Write-Output "[4/6] Building Graph batch requests…"
$batchRequests = [System.Collections.Generic.List[object]]::new()
foreach ($d in $devices) {
    $batchRequests.Add(@{
        id     = "$($d.id)_device"
        method = 'GET'
        url    = "/deviceManagement/managedDevices/$($d.id)"
    })
}

Write-Output "        → Sending batches (size 20)…"
$responses = Invoke-GraphBatch -Requests $batchRequests -ApiVersion 'beta'

Write-Output "        → Detailed responses: $($responses.Count)"

# =========================================
# 5. Transform responses → inventory table
# =========================================
Write-Output "[5/6] Building output rows…"
$inventory = foreach ($resp in $responses) {
    if ($resp.error) {
        Write-Warning "Skipped $($resp.id) – $($resp.error.message)"
        continue
    }
    $device = $resp.body

    # Last logon & last action helpers
    $lastLogon  = $device.usersLoggedOn | Sort-Object lastLogOnDateTime -Descending | Select-Object -First 1
    $lastAction = $device.deviceActionResults | Sort-Object startDateTime -Descending | Select-Object -First 1

    [pscustomobject]@{
        Id                            = $device.id
        DeviceName                    = $device.deviceName
        SerialNumber                  = $device.serialNumber
        Model                         = $device.model
        Manufacturer                  = $device.manufacturer
        OperatingSystem               = $device.operatingSystem
        OSVersion                     = $device.osVersion
        DeviceType                    = $device.deviceType
        JoinType                      = $device.joinType
        AzureADDeviceId               = $device.azureADDeviceId
        ManagedDeviceOwnerType        = $device.managedDeviceOwnerType
        ManagementState               = $device.managementState
        LastSyncDateTime              = $device.lastSyncDateTime
        EnrolledDateTime              = $device.enrolledDateTime
        LastLogOnDateTime             = $lastLogon.lastLogOnDateTime
        LastActionName                = $lastAction.actionName
        LastActionStart               = $lastAction.startDateTime
        LastActionState               = $lastAction.actionState
        UserPrincipalName             = $device.userPrincipalName
        UserDisplayName               = $device.userDisplayName
        WiFiMacAddress                = $device.wiFiMacAddress
        EthernetMacAddress            = $device.ethernetMacAddress
        TotalStorageGB                = [Math]::Round(($device.totalStorageSpaceInBytes / 1GB),2)
        FreeStorageGB                 = [Math]::Round(($device.freeStorageSpaceInBytes  / 1GB),2)
        ComplianceState               = $device.complianceState
        PartnerReportedThreatState    = $device.partnerReportedThreatState
        WindowsActiveMalwareCount     = $device.windowsActiveMalwareCount
        WindowsRemediatedMalwareCount = $device.windowsRemediatedMalwareCount
    }
}

# =====================
# 6. Export & Upload
# =====================

$inventory | Sort-Object UserDisplayName,DeviceName | Export-Csv -Path $localPath -NoTypeInformation -Encoding UTF8
Write-Output "[6/6] CSV created: $fileName ($($inventory.Count) rows)"

# Upload to SharePoint
Add-PnPFile -Path $localPath -Folder $sharePointFolder -Values @{ "Title" = "Intune Device Inventory" }
Write-Output "        → Uploaded to SharePoint: $sharePointFolder/$fileName"

Write-Output "Runbook completed successfully at $(Get-Date -Format 'u')"
