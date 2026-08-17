# Lab 03: DHCP Server Installation & Scope Configuration

## Overview
This lab covers the installation and authorization of the DHCP Server role on `CORP-DC01.corp.local`. Setting up a DHCP scope automates IP address management, default gateway assignment, and DNS server distribution across client endpoints in the `corp.local` enterprise network.

---

## Technical Specifications

| Parameter | Configuration |
| :--- | :--- |
| **DHCP Server** | `CORP-DC01.corp.local` (`192.168.1.10`) |
| **DHCP Scope Name** | `CorpNet-Client-Subnet` |
| **Subnet Range** | `192.168.1.100` – `192.168.1.200` (`/24`) |
| **Subnet Mask** | `255.255.255.0` |
| **Router (Default Gateway)** | `192.168.1.1` |
| **DNS Server** | `192.168.1.10` |
| **Domain Name** | `corp.local` |
| **Lease Duration** | 8 Days |

---

## Step-by-Step Configuration

### Phase 1: Install & Authorize the DHCP Server Role
1. Log in to `CORP-DC01` using the `CORP\Administrator` account.
2. Open **Server Manager**, click **Manage** (top-right), and select **Add Roles and Features**.
3. Advance to the **Server Roles** section, check **DHCP Server**, and click **Add Features** in the popup window.
4. Click **Next** through the default prompts, then click **Install**.
5. Once installation finishes, click the notification **Flag icon** at the top of Server Manager and select **Complete DHCP configuration**.
6. In the wizard, click **Next**, verify **Use the AD DS user's credentials** (`CORP\Administrator`) is selected, click **Commit**, and then click **Close** to authorize the DHCP server in Active Directory.

---

### Phase 2: Configure & Activate the IPv4 DHCP Scope
1. In **Server Manager**, click **Tools** $\rightarrow$ **DHCP**.
2. Expand `CORP-DC01.corp.local` in the left tree menu.
3. Right-click **IPv4** and select **New Scope...**.
4. Set the scope **Name** to `CorpNet-Client-Subnet` and click **Next**.
5. Enter the IP address distribution parameters:
   * **Start IP address:** `192.168.1.100`
   * **End IP address:** `192.168.1.200`
   * **Length:** `24`
   * **Subnet mask:** `255.255.255.0`
6. Click **Next** through **Add Exclusions and Delay**.
7. Keep the **Lease Duration** at the default setting (**8 days**) and click **Next**.
8. Select **Yes, I want to configure these options now** and click **Next**.
9. Configure standard scope options:
   * **Router (Default Gateway):** Type `192.168.1.1` and click **Add**. Click **Next**.
   * **Domain Name and DNS Servers:** Ensure Parent domain is set to `corp.local` and IP address `192.168.1.10` is listed under DNS servers. Click **Next**.
10. On the **Activate Scope** screen, select **Yes, I want to activate this scope now** and click **Finish**.

---

## Verification & Key Takeaways
* [x] DHCP Server role successfully installed on `CORP-DC01`.
* [x] Server authorized within Active Directory Domain Services.
* [x] IPv4 scope `CorpNet-Client-Subnet` created and activated.
* [x] Option 003 (Router) and Option 006 (DNS Servers) verified in DHCP Management Console.

**Next Phase:** Lab 04 — Active Directory OU Hierarchy Creation & User Account Provisioning.
