# Lab 04: Active Directory OU Hierarchy & Account Provisioning

## Overview
This lab covers the architectural design and deployment of a structured Organizational Unit (OU) hierarchy in Active Directory Domain Services (`corp.local`). Establishing an enterprise OU layout provides an organized directory tree for applying Group Policy Objects (GPOs) and delegating administrative permissions. Additionally, this lab provisions standard user accounts and Tier-1 administrative credentials following Role-Based Access Control (RBAC) best practices.

---

## Technical Specifications

| Parameter | Configuration |
| :--- | :--- |
| **Domain Name** | `corp.local` |
| **Domain Controller** | `CORP-DC01.corp.local` (`192.168.1.10`) |
| **Root Organizational Unit** | `CorpObjects` |
| **Sub-OUs** | `Admin_Accounts`, `User_Accounts`, `Workstations`, `Servers`, `Groups` |
| **Provisioned Accounts** | `jdoe` (Standard User), `secadmin-t1` (Tier-1 Admin) |

---

## Directory Architecture

```text
corp.local
└── CorpObjects/
    ├── Admin_Accounts/
    │   └── secadmin-t1 (Member of Domain Admins)
    ├── User_Accounts/
    │   └── jdoe (Member of Domain Users)
    ├── Workstations/
    ├── Servers/
    └── Groups/
```

---

## Step-by-Step Configuration

### Phase 1: Build the Active Directory OU Hierarchy
1. Log in to `CORP-DC01` using the `CORP\Administrator` account.
2. Open **Server Manager** -> click **Tools** -> select **Active Directory Users and Computers** (`dsa.msc`).
3. Expand `corp.local` in the left navigation pane.
4. Right-click `corp.local` -> select **New** -> **Organizational Unit**.
5. Set the top-level OU name to `CorpObjects`. Ensure **Protect container from accidental deletion** is checked, then click **OK**.
6. Right-click the newly created `CorpObjects` OU -> select **New** -> **Organizational Unit** to create the following sub-OUs:
   * `Admin_Accounts`
   * `User_Accounts`
   * `Workstations`
   * `Servers`
   * `Groups`

---

### Phase 2: Provision Enterprise User Accounts

1. **Provision Standard User Account (`jdoe`):**
   * Right-click the `User_Accounts` sub-OU -> **New** -> **User**.
   * **First Name:** `John` | **Last Name:** `Doe`
   * **User logon name:** `jdoe`
   * Click **Next**, set a compliant password, check **Password never expires** (for lab testing purposes), and click **Next** -> **Finish**.

2. **Provision Tier-1 Administrative User Account (`secadmin-t1`):**
   * Right-click the `Admin_Accounts` sub-OU -> **New** -> **User**.
   * **First Name:** `SecAdmin` | **Last Name:** `Tier1`
   * **User logon name:** `secadmin-t1`
   * Click **Next**, set a compliant password, check **Password never expires**, and click **Next** -> **Finish**.
   * Right-click `secadmin-t1` -> select **Properties** -> navigate to the **Member Of** tab.
   * Click **Add...**, enter `Domain Admins`, click **Check Names**, and click **OK** to assign administrative privileges.

---

## Verification & Key Takeaways
* [x] Top-level `CorpObjects` container and tier-based sub-OUs established.
* [x] Standard User account (`jdoe`) provisioned under `User_Accounts`.
* [x] Tier-1 Administrative account (`secadmin-t1`) provisioned and added to `Domain Admins`.
* [x] Account configurations verified within the Active Directory Management Console.

**Next Phase:** Lab 05 — Windows Enterprise Endpoint Provisioning, `corp.local` Domain Join, & DHCP Lease Verification.
