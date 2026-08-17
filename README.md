# Enterprise Network Security & Administration Labs

[![Lab Environment](https://img.shields.io/badge/Environment-Oracle%20VirtualBox-blue)](https://www.virtualbox.org/)
[![OS](https://img.shields.io/badge/Server%20OS-Windows%20Server%202022-0078D6)](https://www.microsoft.com/evalcenter/download-windows-server-2022)
[![Focus](https://img.shields.io/badge/Focus-Active%20Directory%20%7C%20SOC%20Telemetry-red)](#)

## Overview

This repository contains hands-on technical documentation, lab write-ups, and security configurations for an enterprise-grade virtual network environment. 

The objective of this project is to build, configure, and monitor a functional corporate network infrastructure—spanning Active Directory Domain Services (AD DS), core network infrastructure controls, and a dedicated security monitoring stack for threat detection and audit logging.

---

## Network Architecture & Lab Stack

```text
               +----------------------------------+
               |        Oracle VirtualBox         |
               +----------------------------------+
                                |
        +-----------------------+-----------------------+
        |                                               |
+-------------------------------+               +-------------------------------+
|     Identity & Directory      |               |     Security & Telemetry      |
|                               |               |                               |
| • Windows Server 2022 AD DS   |               | • SIEM / Log Ingestion        |
| • DNS & DHCP Server Roles     |               | • Endpoint Audit Rules        |
| • Group Policy Objects (GPO)  |               | • IDS Network Sensors         |
+-------------------------------+               +-------------------------------+
```

* *Hypervisor: Oracle VM VirtualBox*

* *Directory Services: Active Directory Domain Services (AD DS), Group Policy Management, DNS/DHCP*

* *Target Nodes: Windows Server 2022, Windows 10/11 Domain Clients*

* *Security Telemetry: Endpoint auditing, log collection, and network traffic monitoring*

## Directory Structure

``
.
├── README.md
└── labs/
    ├── installation-Guides/      # Base OS deployments and software installation steps
    ├── configurations/           # Network routing, AD DS promotion, GPO, and service setups
    └── SecurityTesting/          # Attack simulations, log parsing, audit rules, and SIEM analysis
``

## Lab Modules & Documentation
1. Installation Guides (/labs/installation-Guides/)

    Lab 01: Windows Server 2022 Deployment — Hypervisor resource allocation, ISO setup, and initial base installation.
2. Configurations (/labs/configurations/)

    Lab 02: Static Networking & Hostname Provisioning

    Lab 03: Active Directory Domain Services (AD DS) Promotion & Domain Controller Setup

    Lab 04: DHCP Server Configuration & User/OU Hierarchy Design
3. Security & Testing (/labs/SecurityTesting/)

    Lab 05: Windows Event Log Forwarding & Audit Policy Configuration

    Lab 06: Enterprise Telemetry & Threat Detection Testing
