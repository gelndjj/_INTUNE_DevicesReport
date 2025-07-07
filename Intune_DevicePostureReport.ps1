# Requires Microsoft.Graph.DeviceManagement module
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

$devices = @()
$uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"

Write-Host "Fetching managed devices from Microsoft Graph..."

do {
    $response = Invoke-MgGraphRequest -Uri $uri -Method GET

    foreach ($device in $response.value) {
        $devices += [PSCustomObject]@{
            DeviceName                     = $device.deviceName
            SerialNumber                   = $device.serialNumber
            Model                          = $device.model
            Manufacturer                   = $device.manufacturer
            OperatingSystem                = $device.operatingSystem
            OSVersion                      = $device.osVersion
            DeviceType                     = $device.deviceType
            JoinType                       = $device.joinType
            AADRegistered                  = $device.aadRegistered -as [bool]
            AzureADDeviceId                = $device.azureADDeviceId
            EnrollmentType                 = $device.deviceEnrollmentType
            RegistrationState             = $device.deviceRegistrationState
            AutopilotEnrolled              = $device.autopilotEnrolled -as [bool]
            ManagedDeviceOwnerType         = $device.managedDeviceOwnerType
            ManagementState                = $device.managementState
            ManagementAgent                = $device.managementAgent
            IsEncrypted                    = $device.isEncrypted -as [bool]
            JailBroken                     = $device.jailBroken
            ComplianceState                = $device.complianceState
            LastSyncDateTime               = $device.lastSyncDateTime
            EnrolledDateTime               = $device.enrolledDateTime
            EmailAddress                   = $device.emailAddress
            UserPrincipalName              = $device.userPrincipalName
            UserDisplayName                = $device.userDisplayName
            ManagedDeviceName              = $device.managedDeviceName
            WiFiMacAddress                 = $device.wiFiMacAddress
            EthernetMacAddress             = $device.ethernetMacAddress
            TotalStorageGB                 = [math]::Round(($device.totalStorageSpaceInBytes / 1GB), 2)
            FreeStorageGB                  = [math]::Round(($device.freeStorageSpaceInBytes / 1GB), 2)
            PartnerReportedThreatState     = $device.partnerReportedThreatState
            WindowsActiveMalwareCount      = $device.windowsActiveMalwareCount
            WindowsRemediatedMalwareCount  = $device.windowsRemediatedMalwareCount
            ChassisType                    = $device.chassisType
            IsSupervised                   = $device.isSupervised -as [bool]
            RetireAfterDateTime            = if ($device.retireAfterDateTime -eq '0001-01-01T00:00:00Z') { $null } else { $device.retireAfterDateTime }
            ManagementCertificateExpiry    = $device.managementCertificateExpirationDate
            Notes                          = $device.notes
        }
    }

    $uri = $response.'@odata.nextLink'
} while ($uri)

# Export to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputPath = ".\EntraDevices_Report_$timestamp.csv"
$devices | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete: $outputPath"
