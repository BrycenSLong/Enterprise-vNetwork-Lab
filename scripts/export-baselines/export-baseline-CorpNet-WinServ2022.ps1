# ==========================================
# Script: export-baseline.ps1
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
