# Lab 08: Wazuh EDR VM set up, agent installation, and log verification

## !!! IN PROGRESS !!!

## Configuration


## Phase 1: Set Up Wazuh Manager's VM
    1. Visit the Linux Mint Website (https://linuxmint.com/)
    2. To save on RAM and CPU usage, use the Xfce Edition. Click Download in the Xfce Edition section.
    3. Select `Purdue Linux Users Group` in the editions list.
    4. Go to Virtual Box and Select `New` to create a new VM.
    5. For `VM Name`, type `CorpWazuhServer01`.
    6. For `ISO Image`, select the drop down menu on the right of the field >> Other >> Downloads. Select the ISO that was just downloaded from the Linux Mint website.
    7. For unattended install, set a password, and then select finish
    8. Right click the `CorpWazuh Server01` >> Settings >> System.
    9. For `Base Memory` allocate 7000MB for this resource.
    10. Click the `Processor` tab and allocate 4 cores to the vCPU. 
    11. Click OK and then go to Media in the left bar >> right click CorpWazuhServer01.vdi >> Properties.
    12. Use the sliding bar at the bottom to adust the Disk Space to 30-50+. (For this lab I did 40GB) Once Adjusted select `Apply`.
    13. Right Click the `CorpWazuhServer01` VM and Select `Settings`.
    14. Click the `Expert` tab and select `Storage` in the left hand menu.
    15. Select the Empty Disk under Devices, and under `Controller: IDE`, then on the far right under Attributes, click the small Blue Disc icon, then select `Choose a disk file....`
    16. Browse and select your Mint Linux ISO. Make sure `LIVE CD/DVD` is checked.
    17. Select `Machines` in the left side bar and double click `CorpWazuhServer01` to run the newly created VM.
    18. When the GRUB screen appears, select the option to run Mint Linux.

## Phase 3: Complete Mint Linux install inside of VM and finish user set up

Note: For now we will set up the Security Engineer account since a lot of the configuring will be happening first. The article will be updated to include methods to add an analyst account. Once added, the rights and permissions will be reconfigured. For now, due to a time crunch before a networking event I will just focus on getting the VM up and slightly configured.

### Part 1: OS installation and user first time set up
    1. In the top right corner, select the CD Icon that is labled `Install Linux Mint`. 
    2. Select your prefered Language >> Continue >> Keyboard Layout >> Continue. (For my set up English was selected.)
    3. If it asks to reformat your drive, then confirm that we want to.
    4. In the `Who are you?` window, fill out the information. For `Your name` I put LabManager, `Your computer's name` was labeled `SOC-WAzuh`, and `Pick a username` it was labeled `secengineer`.
    5. For OS hardening it's a good Idea as well to require a password to log in and to encrypt your home folder, so both of these were selected. Once everything is completed, click `Continue` to finish installing. 
    6. Once the pop up notification labled `Installation Complete`, select Restart Now.
    7. You will be met with the typical screen you'll see on a fresh Mint Install that reads 'Please Remove the installation media and press ENTER'. Click the screen and press Enter to continue booting into the freshly installed OS.
    8. When On the Login screen, enter in the password to verify our configurations work.
    9. Once successfully logged in, you can exit out of the VM. Make sure you select `Power off the machine` and then click OK.
    10. As standard precaution and to practice responsible back up processes, we will take a snapshot of this VM. To do this, make sure you have the `Machines` tab selected in the left hand side bar, click the `CorpWazuhServer01` VM to have it highlighted, and then in the top left select the icon with a camera with a plus labeled 'Take'.
    11. For `Snapshot Name` enter `Base install' into the field and select OK.

## Phase 2: Configure VM Network Access

Note: Since this network is airgapped and we need internet access to install wazuh we will use both the internal adapter for the air gapped network and a different one for actual internet access. Once Wazuh is installed we can switch off the virtual NIC with internet access.

### Part 1: Configure Network Adapters

    1.  In Virutal Box with `CorpWazuhServer` powered off, right click this VM and select settings.
    2. Select `Expert` in the top left corner of the Settings pop up window and Select `Network` in the left hand options.
    3. Int the middle of the box under `Network` ensure that the Adapter 1 tab is selected and the `Enable Network Adapter` check box is selected. For the `Attached to` feild select `Internal Network` and ensure the `Name` field is labled `CorpLabNet`.
    2. Select the `Adapter 2` tab in the `Network` box. Ensure the `Enable Network Adapter` check box is selected. For the `Attached to` feild select `NAT`.

### Part 2: Configure Static IP for the Internal Adapter on the Linux Box

    1. Power on `CorpNet-WinServ2022` and login as admin.
    2. Power on the VM and login as LabManager.
    3. Open the terminal and type: 

``bash
ip -br addr

`` 
    4. You should see IP addresses automatically assigned for both adapters. The next step is to assign a static IP address for the internal adapter for the Linux box. To do this open Network connections by searching in the GUI or via terminal by typing `nm-connection-editor` and pressing enter.
    5. Under Ethernet in the Network Connections window, double click `Wired connection 1`.
    6. Select the `IPv4 Settings` tab. For the `Method` field, select `manual` from the drop down menu.
    7. In the `Addresses` section select the `Add` button on the right. Fill in the feilds with the corisponding IP Adresses:

* *Address:*192.168.1.30
* *Netmask:* 255.255.255.0
* *Gateway:* 192.168.1.1

    8. Once filled in, click `Save` in the bottom right corner of the window. If any errors occur, you will see them in the terminal's output.
    9. To terminate the program, click in your terminal window and press `Ctrl + C`.

### Part 3: Test Configurations

    1. To clear the output in your terminal press:
``bash

~$ clear

``

    Turn on the DC01 VM and login. Check the Ipv4 address. You can either check this in the Settings app or by using the command:

``PowerShell

ipconfig

``

    2. To ensure ICMP packets are not blocked by the firewall, open a Powershell terminal on DC01 as the Administrator and use this command to allow pings to go through and get a response:

``PowerShell

Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

``

    3. Now ping the DC01 computer:

``bash

ping -c 3 <DC01_IP_Address>

``
    4. Check in server manager >> Local Server on `CorpNet-WinServ2022` to get your IP address for the AD server.

    5. On `CorpWazuhServer01` ping the Active Directory Server:

``bash

ping -c 3 <AD_SERVER_IP_ADDRESS>

`` 

## Phase 3: Install Wazuh on the new VM

    1. Update repository indexes and install required utilities for wazuh installation:

``bash

sudo apt update && sudo apt install -y curl apt-transport-https gpg net-tools

``

    2. Download the official Wazuh automated installer:

``bash

curl -sSL https://packages.wazuh.com/4.9/wazuh-install.sh -o wazuh-install.sh

`` 

    3. Verify the file exists and check its size:

``bash

ls -lh wazuh-install.sh

``


    4. Confirm that the download file contains the bash script header instead of HTML:

``bash

head -n 5 wazuh-install.sh

``


    5. Execute the All-in-One installation script:

``bash

sudo bash ./wazuh-install.sh -a

``

    6. Once installation is complete, note down your default username and password that has been displayed in th output. This can be changed, but for now we will keep this the same until I update the document with steps on how to change this.
    7. Verify that the manager is working by going to Firefox and typing in ``https:<YOUR_WAZUH_BOX_IPv4_ADDRESS>:443`. Since we did not set up a cetificate for this, you will be me with a page that says ``Warning: Potential Security Risk Ahead``. Click `Advanced...` and then click `Accept the Risk and Continue`.
    8.Once you see the Wazuh login page, type in the username and password provided in the download output from your terminal earlier. If successful you will be brought to the default dashboard.

## Phase 4: Agent Installation

## Phase 5: Verify Correct Configurations
