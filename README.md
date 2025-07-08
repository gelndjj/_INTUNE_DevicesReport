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
| `Id` | Unique Intune device ID (used for Graph queries) |
| `DeviceName` | Name of the device |
| `SerialNumber` | Device serial number |
| `Model` / `Manufacturer` | Hardware identifiers |
| `OperatingSystem` / `OSVersion` | OS type and version (e.g., Windows 11, iOS) |
| `DeviceType` | Device form factor (e.g., windowsRT, mobile, etc.) |
| `JoinType` | Entra ID join status (`azureADJoined`, `azureADRegistered`, etc.) |
| `AADRegistered` | Whether the device is registered in Entra ID |
| `AzureADDeviceId` | Azure AD device GUID |
| `EnrollmentType` | Enrollment method (Autopilot, manual, etc.) |
| `RegistrationState` | Registration state in Intune |
| `AutopilotEnrolled` | Whether Autopilot was used for setup |
| `ManagedDeviceOwnerType` | Ownership: `company` or `personal` |
| `ManagementState` / `ManagementAgent` | Intune management state and agent |
| `IsEncrypted` | Device encryption status (BitLocker/FileVault/etc.) |
| `JailBroken` | Jailbreak/root detection (mostly for mobile) |
| `ComplianceState` | Intune compliance status |
| `LastSyncDateTime` / `EnrolledDateTime` | Last successful sync and first enrollment time |
| `EmailAddress` / `UserPrincipalName` / `UserDisplayName` | Linked user account info |
| `ManagedDeviceName` | Internal managed name in Intune |
| `WiFiMacAddress` / `EthernetMacAddress` | Network MAC addresses |
| `TotalStorageGB` / `FreeStorageGB` | Disk size and free space in GB |
| `PartnerReportedThreatState` | Device threat level from partners like Defender ATP |
| `WindowsActiveMalwareCount` / `WindowsRemediatedMalwareCount` | Number of detected and remediated threats |
| `ChassisType` / `IsSupervised` | Physical form factor & supervision state |
| `RetireAfterDateTime` | Scheduled retirement time if applicable |
| `ManagementCertificateExpiry` | Intune management certificate expiry date |
| `Notes` | Admin notes from Intune |
| `LastActionName` / `LastActionStart` / `LastActionState` | Most recent Intune action (e.g., wipe, reboot), start time, and result |
| `LastLogonDateTime` | Last recorded user login timestamp |

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
IntuneDevices_Report_YYYYMMDD_HHMMSS.csv
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
