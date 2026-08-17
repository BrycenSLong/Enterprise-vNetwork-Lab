# Lab 02: Static Networking, Hostname Provisioning & AD DS Promotion

## Overview
This lab covers the essential pre-requisites and deployment steps for configuring `CorpNet-WinServer2022` as a Domain Controller. This includes assigning a static IPv4 address, updating the server hostname to follow enterprise naming conventions, installing the Active Directory Domain Services (AD DS) role, and promoting the server to establish a new Active Directory forest (`corp.local`).

---

## Technical Specifications

| Parameter | Configuration |
| :--- | :--- |
| **Hostname** | `CORP-DC01` |
| **Domain Name** | `corp.local` |
| **IPv4 Address** | `192.168.1.10` |
| **Subnet Mask** | `255.255.255.0` (`/24`) |
| **Default Gateway** | `192.168.1.1` |
| **Preferred DNS Server** | `192.168.1.10` (Self-Referential / Loopback) |
| **Server Roles** | Active Directory Domain Services (AD DS), DNS Server |

---

## Step-by-Step Configuration

### Phase 1: Assign a Static IP Address
Active Directory and DNS require a fixed IP address to prevent service disruption and loss of domain controller reachability.

1. In the `CorpNet-WinServer2022` VM, open **Server Manager**.
2. Click **Local Server** in the left navigation pane.
3. Click the blue hyperlink next to **Ethernet** to open the **Network Connections** window.
4. Right-click the primary network adapter (`Ethernet`) and select **Properties**.
5. Highlight **Internet Protocol Version 4 (TCP/IPv4)** and click **Properties**.
6. Select **Use the following IP address** and enter the target subnet values:
   * **IP address:** `192.168.1.10`
   * **Subnet mask:** `255.255.255.0`
   * **Default gateway:** `192.168.1.1`
7. For **Preferred DNS server**, enter `192.168.1.10` since this server will host the primary DNS role.
8. Click **OK**, then click **Close**.

---

### Phase 2: Rename the Host Computer
A default Windows Server installation assigns a randomized hostname (e.g., `WIN-A1B2C3D4E5F`). Renaming the server prior to AD DS promotion prevents broken SID and domain relationship issues.

1. Return to **Server Manager** $\rightarrow$ **Local Server**.
2. Click the hyperlink next to **Computer name**.
3. In the **System Properties** window, click **Change...**.
4. Enter the preferred enterprise hostname: `CORP-DC01`.
5. Click **OK**, accept the prompt warning that a restart is required, and click **Restart Now**.

---

### Phase 3: Install Active Directory Domain Services (AD DS) Role
After the server reboots and administrative logon is complete:

1. Open **Server Manager** and click **Manage** (top-right) $\rightarrow$ **Add Roles and Features**.
2. Click **Next** until reaching the **Server Roles** selection page.
3. Check the box for **Active Directory Domain Services**.
4. In the pop-up prompt, click **Add Features**, then click **Next** through the remaining wizard defaults.
5. Check the option to **Restart the destination server automatically if required** and click **Install**.

---

### Phase 4: Promote the Server to a Domain Controller
1. Once installation completes, click the **Flag icon** (Notifications) in the top navigation bar of Server Manager.
2. Click **Promote this server to a domain controller**.
3. Under Deployment Configuration, select **Add a new forest**.
4. Enter the root domain name: `corp.local` and click **Next**.
5. Set a strong **Directory Services Restore Mode (DSRM)** password and proceed through the remaining wizard defaults.
6. Click **Install**. The server will process the promotion, automatically reboot, and allow authentication under the new domain (`CORP\Administrator`).

---

## Verification & Key Takeaways
* [x] Static IP configuration verified via `ipconfig /all`.
* [x] Hostname updated to `CORP-DC01`.
* [x] AD DS and DNS roles installed.
* [x] Active Directory forest `corp.local` established.

**Next Phase:** Lab 03 — DHCP Server Role Installation, Scope Configuration, and Domain OU/User Hierarchy Creation.
