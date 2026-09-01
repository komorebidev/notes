# Bicep

## Run command

```powershell
$clientIp = (Invoke-RestMethod -Uri "https://ipinfo.io/ip"); az deployment sub create --location koreacentral --template-file main.bicep --parameters clientIp=$clientIp adminUsername='azureuser' adminPassword='Toranomon4128!'
```

## Initializing 200gb data disk

- This disk is created by Bicep but needs to be initialized manually from disk management

## Scripts inside temp folder

- Sometimes deploy won't run the scripts
- Just run them manually in that case from temp folder

## Cleanup entra on decommission

- Delete from Entra ID from devices tab
- Otherwise redeploy will have issues
- Or can try command...

```powershell
$deviceId = (az rest --method GET --url "https://graph.microsoft.com/v1.0/devices" --query "value[?displayName=='plant-pyvm'].id | [0]" -o tsv).Trim()

if (-not [string]::IsNullOrEmpty($deviceId) -and $deviceId -ne "None" -and $deviceId -ne "null") {
    Write-Host "Found device ID: $deviceId"
    az rest --method DELETE --url "https://graph.microsoft.com/v1.0/devices/$deviceId"
    Write-Host "Stale Entra ID device 'plant-pyvm' successfully deleted."
} else {
    Write-Host "No matching device found in Entra ID."
}
```

## Check cloud-init run status

```powershell
sudo cat /var/log/cloud-init-output.log
```

- This also shows the OpenVPN Access Server login info

## Extra things which were needed to get things working

# Full Setup Summary: OpenVPN, Azure DNS, Entra ID RDP

## 1. Debian Server `dnsmasq` Installation & Configuration
- Update and install `dnsmasq`:
  ```bash
  sudo apt update
  sudo apt install dnsmasq -y
  ```
- Configure listen addresses and conditional forwarding in the configuration file (e.g., `/etc/dnsmasq.conf` or `/etc/dnsmasq.d/azure.conf`):
  ```text
  listen-address=127.0.0.1,10.8.0.1
  bind-interfaces
  server=/corp.internal/168.63.129.16
  ```
- Restart and enable the service:
  ```bash
  sudo systemctl restart dnsmasq
  sudo systemctl enable dnsmasq
  ```

  - Had to add the App subnet to the OpenVPN access server global access rules allowed traffic subnets for NAT

## 2. Azure Infrastructure & DNS Configuration
- Created an Azure Private DNS Zone named `corp.internal`.
- Linked the Private DNS Zone to the target Azure Virtual Network with **Auto-registration** enabled.

## 3. OpenVPN Server Settings
- Configured OpenVPN Access Server to push the Debian server's VPN interface IP (`10.8.0.1`) as the primary DNS resolver. (or bind to adapters instead)
- Pushed `corp.internal` as the DNS search domain to connected client machines.

- Also needed to setup enterprise app in Azure for SAML entra authentication

## 4. Microsoft Entra ID & Extension Setup on the VM
- Navigated to the Windows Server VM in the Azure Portal.
- Opened **Extensions + applications** -> **Add** -> installed the **Microsoft Entra Login** (`AADLoginForWindows`) extension.

## 5. Azure RBAC Role Assignment
- Navigated to the target Virtual Machine (`plant-pyvm`) in the Azure Portal.
- Clicked **Access control (IAM)** -> **Add** -> **Add role assignment**.
- Selected the **Virtual Machine Administrator Login** role.
- Selected **User, group, or service principal**, added your user account, and completed the assignment.

## 6. Windows Server OS Identity & Suffix Configuration
- Kept the local computer hostname as `plant-pyvm`.
- Opened `sysdm.cpl` -> **Computer Name** tab -> **Change** -> **More...**
- Set the **Primary DNS Suffix of this computer** to `corp.internal`.
- Restarted the VM to bind cryptographic tokens and FQDN registration.

## 7. Final RDP Connection
- Connected to the full-tunnel OpenVPN client.
- Launched Remote Desktop (`mstsc`).
- Targeted the exact FQDN: `plant-pyvm.corp.internal`.
- Checked **"Use a web account to sign in to the remote computer"** under the Advanced tab and authenticated successfully with Entra ID credentials.

# Azure POC Network Design

## Overview

This Bicep template creates the initial Azure networking environment for a small enterprise POC that is expected to eventually transition into production.

The design intentionally keeps the network small while leaving enough room for future expansion. It uses standard RFC 1918 private address space and avoids overlapping with the organization's existing networks.

The environment currently has fewer than 100 employees, so allocating an unnecessarily large Azure address space such as a `/16` is not required.

---

## Existing Corporate Addressing

The organization's existing networks include:

| Network | CIDR |
|---|---|
| AP_MGMT | `10.0.10.0/24` |
| CORP_LAN | `10.0.20.0/24` |
| VOIP_LAN | `10.0.30.0/24` |
| AV_LAN | `10.0.40.0/24` |
| SECURITY_VLAN | `10.0.70.0/24` |
| JapanEntry | `10.0.80.0/24` |
| Corp | `10.0.90.0/24` |
| Guest | `192.168.88.0/24` |
| FortiLink | `10.255.1.0/24` |
| Quarantine | `10.255.11.0/24` |
| RSPAN | `10.255.12.0/24` |
| NAC_Segment | `10.255.13.0/24` |

The Azure address space was selected from a separate portion of RFC 1918 private space:

```text
10.100.0.0/20
```

## VNet Design

```text
VNet
10.100.0.0/23
│
├── snet-vpn
│   10.100.0.0/27
│
├── snet-app
│   10.100.0.32/26
│
├── snet-private-endpoints
│   10.100.0.96/26
│
└── snet-management
    10.100.0.160/27
```

## VNet Subnet Allocation

| Subnet Name | CIDR | Prefix | Total IPs | Azure Usable IPs | Purpose |
|---|---|---:|---:|---:|---|
| `snet-vpn` | `10.100.0.0/27` | /27 | 32 | 27 | OpenVPN server |
| `snet-app` | `10.100.0.32/26` | /26 | 64 | 59 | Application workloads |
| `snet-private-endpoints` | `10.100.0.96/26` | /26 | 64 | 59 | Azure Private Endpoints |
| `snet-management` | `10.100.0.160/27` | /27 | 32 | 27 | Management resources |
| **Unallocated / Reserved** | `10.100.0.192/26` | /26 | 64 | 59 | Reserved for future requirements |

> **Azure subnet note:** Azure reserves 5 IP addresses from each subnet (the first four and the last address).

## Address Hierarchy

| Level | CIDR | Purpose |
|---|---|---|
| Azure planned allocation | `10.100.0.0/20` | Reserved in IPAM/documentation for Azure |
| Production VNet | `10.100.0.0/23` | Actual Azure VNet |
| `snet-vpn` | `10.100.0.0/27` | OpenVPN server |
| `snet-app` | `10.100.0.32/26` | Application workloads |
| `snet-private-endpoints` | `10.100.0.96/26` | Private Endpoints |
| `snet-management` | `10.100.0.160/27` | Management resources |
| Reserved inside VNet | `10.100.0.192/26` | Future expansion |
| VPN client pool | `10.100.8.0/24` | OpenVPN/P2S client addresses |

## Address Space

```text
10.100.0.0/20 — Azure planned allocation
│
├── 10.100.0.0/23 — Production VNet
│   │
│   ├── 10.100.0.0/27     — snet-vpn
│   ├── 10.100.0.32/26    — snet-app
│   ├── 10.100.0.96/26    — snet-private-endpoints
│   ├── 10.100.0.160/27   — snet-management
│   └── 10.100.0.192/26   — Reserved
│
└── Remaining 10.100.2.0/23 - 10.100.15.255
    └── Reserved for future Azure requirements

10.100.8.0/24 — VPN client pool
```