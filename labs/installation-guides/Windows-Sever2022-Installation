# Lab 01: Windows Server 2022 Base Deployment & VM Setup

## Overview
This initial lab covers the setup and deployment of Microsoft Windows Server 2022 (Evaluation) within an Oracle VirtualBox environment. This server will serve as the core Infrastructure & Identity Controller (Domain Controller / Active Directory / DNS / DHCP) for the enterprise network lab environment.

---

## Technical Specifications & Resource Allocation

| Parameter | Configuration |
| :--- | :--- |
| **Virtual Machine Name** | `CorpNet-WinServer2022` |
| **Operating System** | Windows Server 2022 Standard Evaluation (Desktop Experience) |
| **Base Memory (RAM)** | 6291 MB (~6 GB) |
| **Virtual Processors** | 3 vCPUs |
| **Virtual Disk Size** | 50 GB (Dynamic Allocation) |
| **Hypervisor** | Oracle VM VirtualBox |

---

## Step-by-Step Installation

### Phase 1: ISO Acquisition & Virtual Machine Creation
1. Downloaded the Windows Server 2022 Evaluation ISO directly from the [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022).
2. Selected the **64-bit ISO Edition** (`English - United States`).
3. Opened VirtualBox and clicked **New** to initiate VM creation:
   * **Name:** `CorpNet-WinServer2022`
   * **ISO Image:** Selected the downloaded Windows Server 2022 ISO file.
   * **Unattended Install:** Checked **Skip Unattended Installation** to prevent VirtualBox unattended script errors and enable manual deployment.
4. Allocated physical hardware resources:
   * **RAM:** `6291 MB`
   * **CPU Cores:** `3 vCPUs`
   * **Disk Storage:** `50 GB`

---

### Phase 2: Operating System Deployment
1. Launched the `CorpNet-WinServer2022` VM from the VirtualBox Manager.
2. Verified default region settings (**Language:** `English (United States)`) and selected **Install Now**.
3. Selected **Windows Server 2022 Standard Evaluation (Desktop Experience)** to install the full graphical user interface (GUI).
4. Accepted the Microsoft Software License Terms.
5. Selected **Custom: Install Microsoft Server Operating System only (advanced)** to perform a clean installation.
6. Selected the provisioned 50 GB unallocated virtual disk space and proceeded with the installation.

---

### Phase 3: Post-Installation & Initial Logon
1. After the setup process completed, set a strong local **Administrator** password on the **Customize settings** screen.
2. Sent the `Ctrl + Alt + Delete` interrupt signal to the VM using the VirtualBox host key combination (**Right Ctrl + Delete**) to access the Windows login prompt.
3. Authenticated into the desktop environment using the local Administrator account.

---

## Verification & Next Steps
* [x] Hypervisor resource allocation validated.
* [x] Windows Server 2022 Desktop Experience successfully installed.
* [x] Administrative authentication confirmed.

**Next Phase:** Initial Server Hardening (Static IP Allocation, Hostname Configuration, and AD DS / DNS Role Installation).
