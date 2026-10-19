# Lab 09: Windows Server Baseline Extraction

## Summary

This lab established a fully automated, host-bridged baseline extraction framework for the Windows Server 2022 Domain Controller (`CorpNet-WinServ2022`). By leveraging VirtualBox Guest Additions and cross-platform shared folders (`\\vboxsrv\config-backups` mapped to `Z:\`), environment configurations are exported directly to the Linux Mint host filesystem without requiring network file shares or external storage media.

The execution of `export-baseline-CorpNet-WinServ2022.ps1` successfully captured 11 critical infrastructure layers—including Active Directory domain objects (OUs, Users, Groups, Computers), Group Policy Objects (GPOs), Local Security Policies, DNS zones/records, DHCP scopes, AD Sites/Subnets, and Sysmon telemetry rules—into version-controllable CSV, XML, INF, and TXT artifacts. This dataset serves as the state baseline required to execute fully automated, idempotent rebuilds of the `corpnet.local` domain from a fresh Windows Server ISO.

---

## Phase 1: Install powershell
I'm a daily linux driver, so we need to install PowerShell

```bash

# Download the Microsoft repository package explicitly targeting noble (Ubuntu 24.04)
wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install the repository configuration package
sudo dpkg -i packages-microsoft-prod.deb

# Update package list
sudo apt update

# Install PowerShell
sudo apt install -y powershell

# Remove the leftover .deb package file from your home directory:
rm packages-microsoft-prod.deb

```

## Phase 2: Create Shared Folder to Push VM Configuration Back Ups to

### Step 1: Set Up a Shared Folder in VirtualBox
1. In your terminal create the directory for the backup. Use this command and replace `{YOUR_USERNAME}` with your username on your machine:

```Bash

mkdir -p /home/brycen/Desktop/Enterprise-vNetwork-Lab/build/config-backups

```

2. In VirtualBox on Linux Mint, go to Settings for CorpNetDC01 >> `Shared Folders`.
3. Click the Add Folder (+ icon) and configure:
* *Folder Path:* `/home/{YOUR_USERNAME}/Desktop/Enterprise-vNetwork-Lab/build/config-backups`
* *Folder Name:* `config-backups`
* Check `Auto-mount` and `Make Permanent`.
4. Select the `OK` options to confirm this change.
5. Boot the VM. In Windows, this folder will automatically appear as a network drive (e.g., `Z:\` or `\\vboxsrv\config-backups`)
6. Select `Devices` in the top VM window bar >> `Insert Guest Additions CD image..`

* *Verification:* Open `File Explorer` >> `This PC`. You should see `CD Drive (D:) VirtualBox Guest Additions` as an availible drive.

6. Open PowerShell (Admin) on CorpNet-WinServ2022 and run the installer directly from the single mounted drive:

```PowerShell

# Run Guest Additions silent installer
Start-Process -FilePath "D:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait

# Reboot the VM to load kernel drivers
Restart-Computer

```

7. Remove any existing PSDrive mapping or any persistent Windows network drive mapping for Z:

```PowerShell

# Remove any existing PSDrive mapping for Z:
Remove-PSDrive -Name "Z" -Force -ErrorAction SilentlyContinue

# Remove any persistent Windows network drive mapping for Z:
net use Z: /delete /y

``` 

* *Verification:* Run `Get-PSDrive Z` in PowerShell. It should return an error stating Cannot find drive, confirming `Z:` is completely unmapped and available.

8. Re-execute the mapping command to blind `Z:` directly to your Linux Mint host folder:

```PowerShell

New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\vboxsrv\config-backups" -Persist

```

* *Verification:* Run `Get-ChildItem Z:\` in PowerShell inside Windows. It will list the contents of your Linux Mint host folder /home/{YOUR_USERNAME}/Desktop/Enterprise-vNetwork-Lab/build/config-backups.

### Step 2: Export Configurations Directly to the Host Directory
execute your export commands directly against the shared mount path in PowerShell (Admin) inside the VM:

```PowerShell

# Ensure the destination directories exist on the mapped Z: drive
New-Item -ItemType Directory -Force -Path "Z:\gpo-backups" | Out-Null

# 1. Export Active Directory GPOs
Backup-Gpo -All -Path "Z:\gpo-backups"

# 2. Export Sysmon Config (if present)
if (Test-Path "C:\Windows\sysmonconfig.xml") {
    Copy-Item -Path "C:\Windows\sysmonconfig.xml" -Destination "Z:\sysmonconfig.xml"
}

# 3. Export Active Directory Domain Baseline Metadata
Get-ADDomain | Select-Object Name, DNSRoot, DomainSID, Forest | Export-Clixml -Path "Z:\ad-domain-info.xml"

```

### Phase 3: Create, Store, and Run Basline Export script:
1. On the Linux Host, create a scripts directory. Open a terminal and type:

```Bash

mkdir -p ~/Desktop/Enterprise-vNetwork-Lab/scripts

```

2. Open nano to reate and edit the script

```Bash

nano ~/Desktop/Enterprise-vNetwork-Lab/scripts/export-baseline-CorpNet-WinServ2022.ps1

```

3. Put this code into your PowerShell script:

```PowerShell

# ==========================================
# Script: export-baseline-CorpNet-WinServ2022.ps1
# Description: Exports GPOs, local policies, network settings, Sysmon config, 
#              DNS, DHCP, AD sites, and all AD objects to Z:\CorpNet-WinServ2022
# Target Execution: CorpNetDC01 (Windows Server VM)
# ==========================================

Write-Host "[+] Initializing Full Environment Export to Linux Mint Host..." -ForegroundColor Green

# Define base export path on mounted shared drive
$ExportPath = "Z:\CorpNet-WinServ2022"

# 1. Ensure Z: drive shared folder is active
if (-not (Test-Path "Z:\")) {
    Write-Host "[*] Mounting Z:\ shared folder..." -ForegroundColor Yellow
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\vboxsrv\config-backups" -Persist | Out-Null
}

# 2. Create target subdirectories on Linux Mint host folder
New-Item -ItemType Directory -Force -Path "$ExportPath\gpo-backups" | Out-Null

# 3. Export Domain Group Policy Objects (GPOs)
Write-Host "[*] Exporting Active Directory Domain GPOs..." -ForegroundColor Cyan
Backup-Gpo -All -Path "$ExportPath\gpo-backups"

# 4. Export Local Security Policy (User Rights, Password Policies, Audit Policies)
Write-Host "[*] Exporting Local Security Policy..." -ForegroundColor Cyan
secedit.exe /export /cfg "$ExportPath\local-security-policy.inf"

# 5. Export Sysmon Config (if installed)
if (Test-Path "C:\Windows\sysmonconfig.xml") {
    Write-Host "[*] Exporting Sysmon configuration..." -ForegroundColor Cyan
    Copy-Item -Path "C:\Windows\sysmonconfig.xml" -Destination "$ExportPath\sysmonconfig.xml" -Force
}

# 6. Export Active Directory Domain Identity & Metadata
Write-Host "[*] Exporting Active Directory Domain Metadata..." -ForegroundColor Cyan
Get-ADDomain | Select-Object Name, DNSRoot, DomainSID, Forest | Export-Clixml -Path "$ExportPath\ad-domain-info.xml"

# 7. Export Windows Guest Network Adapter & DNS Config
Write-Host "[*] Exporting Network Adapter and DNS Configurations..." -ForegroundColor Cyan
Get-NetIPConfiguration | Out-File -FilePath "$ExportPath\network-config.txt"
Get-DnsServerForwarder | Out-File -FilePath "$ExportPath\dns-forwarders.txt"

# 8. Export Active Directory Objects (OUs, Users, Groups, Computers, Memberships)
Write-Host "[*] Exporting Active Directory Objects (OUs, Users, Groups, Computers)..." -ForegroundColor Cyan

# Export OUs
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Export-Csv -Path "$ExportPath\ad-ous.csv" -NoTypeInformation

# Export Users
Get-ADUser -Filter * -Properties SamAccountName, UserPrincipalName, Enabled, GivenName, Surname | Export-Csv -Path "$ExportPath\ad-users.csv" -NoTypeInformation

# Export Groups
Get-ADGroup -Filter * | Select-Object Name, GroupScope, GroupCategory, DistinguishedName | Export-Csv -Path "$ExportPath\ad-groups.csv" -NoTypeInformation

# Export Group Memberships
Get-ADGroup -Filter * | ForEach-Object {
    $group = $_.Name
    Get-ADGroupMember -Identity $_ | Select-Object @{N='Group';E={$group}}, SamAccountName, Name, objectClass
} | Export-Csv -Path "$ExportPath\ad-group-members.csv" -NoTypeInformation

# Export Computers (Workstations & Member Servers)
Get-ADComputer -Filter * -Properties Name, OperatingSystem, OperatingSystemVersion, DNSHostName, Enabled | Export-Csv -Path "$ExportPath\ad-computers.csv" -NoTypeInformation

# 9. Export Internal DNS Zones and Resource Records
Write-Host "[*] Exporting DNS Server Zones and Records..." -ForegroundColor Cyan
Get-DnsServerZone | Where-Object { -not $_.IsAutoCreated } | ForEach-Object {
    $ZoneName = $_.ZoneName
    Get-DnsServerResourceRecord -ZoneName $ZoneName | Export-Clixml -Path "$ExportPath\dns-zone-$ZoneName.xml"
}

# 10. Export AD Sites, Subnets, and Site Links
Write-Host "[*] Exporting Active Directory Sites and Subnets..." -ForegroundColor Cyan
Get-ADReplicationSite -Filter * | Export-Clixml -Path "$ExportPath\ad-sites.xml"
Get-ADReplicationSubnet -Filter * | Export-Clixml -Path "$ExportPath\ad-subnets.xml"

# 11. Export DHCP Server Scopes and Reservations (if DHCP role is installed)
if (Get-Command -Name "Get-DhcpServerv4Scope" -ErrorAction SilentlyContinue) {
    Write-Host "[*] Exporting DHCP Server Configuration..." -ForegroundColor Cyan
    Export-DhcpServer -File "$ExportPath\dhcp-config.xml" -Force
}

Write-Host "[+] All exports completed successfully! Full environment baseline stored in $ExportPath" -ForegroundColor Green

```

8. Use `Ctrl + o` to save, press enter to confirm you want to save, and `Ctrl + X` to exit nano.

9. Copy the local file on the mother machine and put this into the shared folder by running this command on your mother OS terminal:

```Bash

cp ~/Desktop/Enterprise-vNetwork-Lab/scripts/export-baseline-CorpNet-WinServ2022.ps1 ~/Desktop/Enterprise-vNetwork-Lab/build/config-backups/

```

10. Verify this was moved by clicking the shared `config-backups (\\VBoxSrv) (Z:)` drive. You should see the script their inside the drive.

11. Run the script inside of CorpNet-WinServ2022 Vm:

```PowerShell

# 1. Allow local script execution for the current session
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

# 2. Execute the script directly from the mounted Z: drive
Z:\export-baseline-CorpNet-WinServ2022.ps1

```

12. If asked about if you would like to run this script, type `R` and press enter. If completed successfully, you will see a green message stating `[+] All exports completed successfully! Output stored in Z:\ (Config-backups/)`



### Phase 4: Verify Configurations Were Moved to Shared Folder

Run this in a terminal on Linux Mint:

```Bash

ls ~/Desktop/Enterprise-vNetwork-Lab/build/config-backups

```

The GPO backup GUID folders and sysmonconfig.xml will appear immediately on your host OS filesystem.

---
## Lessons Learned

* **Hypervisor Storage Bridging:** VirtualBox Shared Folders offer a zero-trust, isolated data pipeline between Linux host environments and Windows guests. Proper setup requires mounting Guest Additions drivers and clearing stale Windows drive letters (`net use Z: /delete /y`) before binding new `PSDrive` targets.
* **Separation of Automation Tools and Data Payload:** Automation scripts must be version-controlled independently in a dedicated `scripts/` directory, while generated runtime exports are directed to `build/config-backups/`. Storing executable scripts directly inside dynamic backup targets risks accidental loss during lab purge cycles.
* **Dependency Sequencing in IaC Rebuilds:** Active Directory objects cannot be restored at random; restoration requires strict hierarchical ordering (Forest/Domain initialization > Organizational Units > Security Groups > Users > Memberships > Policy/DNS).
* **Handling Dynamic Identity Identifiers (SIDs/GUIDs):** Exporting objects via structured CLI tools (`Get-ADUser`, `Backup-Gpo`) captures functional attributes while decoupling them from static Domain SIDs and GUID container bindings, ensuring clean imports onto fresh OS installations.
* **Sensitive Artifact Hygiene:** Referencing extraction scripts helps myself or anyone else that may be following along get around the 180 day timer set on Windows observatory images so the lab can continue to be advanced over time without publically sharing sensitive artifacts within the System build.
