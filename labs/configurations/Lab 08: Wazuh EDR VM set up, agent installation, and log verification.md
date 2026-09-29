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

## Phase 2: Configure rights and permissions

## Phase 3: Install Wazuh on the new VM

## Phase 4: Agent Installation

## Phase 5: Verify Correct Configurations
