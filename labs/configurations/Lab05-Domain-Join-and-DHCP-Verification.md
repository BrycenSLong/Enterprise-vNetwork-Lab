# Lab 05: Enterprise Endpoint Deployment, Domain Join & DHCP Lease Verification

## Overview
This lab covers the deployment of a Windows Enterprise client workstation, attaching it to the isolated `CorpLabNet` internal network, and joining it to the `corp.local` Active Directory domain. Additionally, this lab validates automated IPv4 allocation via the DHCP server role hosted on `CORP-DC01` and tests domain authentication using provisioned Active Directory user credentials.

---

## Technical Specifications

| Parameter | Configuration |
| :--- | :--- |
| **Domain Name** | `corp.local` |
| **Domain Controller / DNS / DHCP** | `CORP-DC01.corp.local` (`192.168.1.10`) |
| **Client Hostname** | `CORP-WIN10` (or `CORP-WIN11`) |
| **Client OS** | Windows 11 Enterprise |
| **Network Adapter Mode** | Internal Network (`CorpLabNet`) |
| **Assigned IPv4 Range** | `192.168.1.100` – `192.168.1.200` (`/24`) |
| **Test Accounts Logged In** | `CORP\jdoe` (Standard User) |

---

## Step-by-Step Configuration

### Phase 1: Configure Endpoint Network Adapter & Verify DHCP Lease
1. Ensure the Windows Enterprise client VM is powered off.
2. In VirtualBox, go to **Settings** -> **Network** -> **Adapter 1**.
3. Set **Attached to:** to **Internal Network** and name it `CorpLabNet`.
4. Power on the client VM and log in to the local administrator account.
5. Open **Command Prompt** (`cmd`) and execute:
   ```cmd
   ipconfig /release
   ipconfig /renew
   ipconfig /all
   ```
6. Verify network lease parameters:
   * **IPv4 Address:** Assigned an IP within `192.168.1.100` – `192.168.1.200`.
   * **Subnet Mask:** `255.255.255.0`
   * **Default Gateway:** `192.168.1.1`
   * **DNS Servers:** `192.168.1.10` (Pointing directly to `CORP-DC01`).
7. Test DNS resolution by pinging the domain name:
   ```cmd
   ping corp.local
   ```

---

### Phase 2: Rename Hostname & Join `corp.local` Domain
1. On the client VM, press `Win + R`, type `sysdm.cpl`, and press **Enter** to open **System Properties**.
2. Click **Change...**.
3. Under **Computer name**, enter `CORP-WIN11-01`.
4. Under **Member of**, select **Domain** and enter `corp.local`. Click **OK**.
5. When prompted for credentials, enter domain administrator credentials:
   * **User:** `CORP\Administrator` (or `CORP\secadmin-t1`)
   * **Password:** `[Your Domain Admin Password]`
6. Accept the welcome message (*"Welcome to the corp.local domain"*), click **OK**, and click **Restart Now**.

---

### Phase 3: Validate Domain Authentication & Directory Objects
1. **Test Domain User Logon:**
   * At the Windows logon screen, select **Other user**.
   * Log in using the standard domain account: `CORP\jdoe` with its assigned password.
   * Verify the profile builds successfully and logs into the Windows desktop environment.

2. **Verify Active Directory Registration (`CORP-DC01`):**
   * Switch to `CORP-DC01` and open **Active Directory Users and Computers** (`dsa.msc`).
   * Expand `corp.local` -> click the **Computers** container.
   * Verify `CORP-WIN10` is listed as a registered Computer object.
   * Right-click `CORP-WIN10` -> select **Move...** -> relocate the computer object into `CorpObjects/Workstations` to maintain proper OU hygiene.

3. **Verify Active DHCP Reservation (`CORP-DC01`):**
   * Open **DHCP Management Console** (`dhcpmgmt.msc`).
   * Expand `IPv4` -> `Scope [192.168.1.0] CorpNet-Client-Subnet` -> **Address Leases**.
   * Confirm `CORP-WIN10` appears with an active lease state, MAC address, and expiration date.

---

## Verification & Key Takeaways
* [x] Windows Enterprise client successfully leased network configuration from `CORP-DC01` DHCP scope.
* [x] Endpoint renamed to `CORP-WIN10` and joined to `corp.local` domain.
* [x] Standard domain user (`CORP\jdoe`) authenticated successfully on the endpoint.
* [x] Active Directory Computer object created and organized into `CorpObjects/Workstations` OU.
* [x] DHCP active lease verified in Server Manager console.

**Next Phase:** Lab 06 — Group Policy Object (GPO) Deployment (Audit Policies, Sysmon, & Security Baseline).
