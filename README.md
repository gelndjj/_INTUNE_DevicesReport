# 🖥️ _INTUNE_DevicesReport

Export a detailed report of all Intune-managed and Entra-registered devices using Microsoft Graph API.  
This PowerShell script provides a **comprehensive view of device state, compliance, encryption, join type, and more** — ideal for **security auditing**, **inventory tracking**, and **lifecycle management**.

## 🚀 Features

- Fetches **all devices** from `deviceManagement/managedDevices` (pagination supported)
- Uses **Microsoft Graph API (beta)** for complete data access
- Outputs a **CSV report** with clean formatting and type conversion
- Handles:
  - Join types (Entra Joined vs Registered)
  - Null values (displayed as blank)
  - Boolean conversions (`true`/`false`)
  - Storage space in **GB**
  - ISO timestamps
- Designed to help **Security and Endpoint Management teams** track device posture across the environment

## 📊 Output Columns

| Column | Description |
|--------|-------------|
| `DeviceName` | Name of the device |
| `SerialNumber` | Device serial number |
| `Model` / `Manufacturer` | Hardware identifiers |
| `OperatingSystem` / `OSVersion` | System type and build |
| `DeviceType` | Form factor (e.g., windowsRT, mobile, etc.) |
| `JoinType` | Entra join status (`azureADJoined`, `azureADRegistered`, etc.) |
| `AADRegistered` | Whether the device is registered in Entra ID |
| `AzureADDeviceId` | Unique Azure AD device ID |
| `EnrollmentType` | How the device was enrolled (Autopilot, BYOD, etc.) |
| `RegistrationState` | High-level registration state |
| `AutopilotEnrolled` | Indicates Autopilot usage |
| `ManagedDeviceOwnerType` | `company` or `personal` |
| `ManagementState` / `ManagementAgent` | Intune management state and agent type |
| `IsEncrypted` | BitLocker/device encryption status |
| `JailBroken` | Compliance status (mobile devices) |
| `ComplianceState` | Intune compliance status |
| `LastSyncDateTime` / `EnrolledDateTime` | Sync and onboarding dates |
| `EmailAddress` / `UserPrincipalName` / `UserDisplayName` | Device owner/user info |
| `ManagedDeviceName` | Internal managed name |
| `WiFiMacAddress` / `EthernetMacAddress` | Network identifiers |
| `TotalStorageGB` / `FreeStorageGB` | Disk space info in GB |
| `PartnerReportedThreatState` | Device risk status |
| `WindowsActiveMalwareCount` / `WindowsRemediatedMalwareCount` | Defender threat data |
| `ChassisType` / `IsSupervised` | Physical form and management supervision |
| `RetireAfterDateTime` / `ManagementCertificateExpiry` | Lifecycle & cert status |
| `Notes` | Admin notes if available |

## 🧠 Prerequisites

- PowerShell 7+ (recommended)
- [Microsoft.Graph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview) PowerShell module
- Entra ID role with **Intune read permissions**
- Connect to Graph:
  ```powershell
  Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
  ```

## 📂 Output

Generates a CSV in the current directory:

```plain
EntraDevices_Report_YYYYMMDD_HHMMSS.csv
```

## 🛠️ Usage

```powershell
# Clone or copy the script locally
.\Intune_DevicePostureReport.ps1
```

The script will fetch all managed devices and export them into a clean, sortable CSV file.

## 🔒 Permissions

This script requires the following Microsoft Graph delegated or application permission:

DeviceManagementManagedDevices.Read.All
You can grant these via Entra ID → App registrations or via delegated sign-in using Connect-MgGraph.
