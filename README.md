# AllthingsTimesketch

<h1>Purpose</h1>
Processing of host triage packages is always a challenge when dealing with incidents involving large number of hosts. 
This repository contains 
- a build script to install and configure Timesketch and associated services

- a workflow built using NodeRED to automate handling of triage packages, plaso processing and ingestion into Timesketch.

- a custom Timesketch tagger file which contains a curated list of pre-built queries (mapped to MITRE ATT&CK were possible). It can be used to quickly identify initial pivot points and get contextual information during investigations. 

<b>Usage Instructions for Timesketch Install Script</b>
Note: You need to be running Ubuntu 20.04 LTS for this.

wget https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh

chmod a+x ./tsplaso_docker_install.sh

sudo ./tsplaso_docker_install.sh

<b>Tagger file for faster triage</b>
Use the following tags file to get most out of TS (It is already part of the tsplaso_docker_install.sh script
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/tags.yaml

<h1> Automating DFIR Triage Processing Workflow</h1>
My inspiration for the following workflow was from the work carried by Eric Capuano (AWS DFIR Automation) and knowledge sharing sessions with Mike Pilkington. Special thanks to Sam Machin (https://github.com/sammachin) for his continous support with troubleshooting Node-RED workflow issues with me. 

<h2>Node-RED Automation to handle triage processing</h2>
Node-RED is a browser based flow editor which provides an easier way to achieve automation. I've created an automation flow where the flow will watch for ZIP files in /cases/processor directory. When new triage zip files get uploaded (Tested with CyLR and KAPE zips) it will automatically unzip into a unique folder, parses it with Log2timeline and ingests into Timesketch using Timesketch-Importer script. It has the ability to queue up zip files for processing. This was you can control how many zips gets processed at a point in time. 

NOTICE : This workflow currently do not process disk images at this point in time. However, I am planning to have that included in the near future.

Pre-requisites
---------------------
1. Install Node-RED using the instructions given at https://nodered.org/docs/getting-started/. I've tested this on Ubuntu 20.04 (https://nodered.org/docs/getting-started/raspberrypi)
2. This automation depends on the following additonal nodes. I recommend installing it directly via the GUI -> Manage Pallette -> Install after you install Node-RED
NOTICE - I have removed the unzip node from the flow as it had some issues with certain zip files. Latest flows uses the "unzip" utility available for Linux. Therefore, make sure you have it pre-installed before using this flow.
-node-red-contrib-fs
-node-red-contrib-fs-ops
-node-red-contrib-simple-queue
-node-red-contrib-watchdirectory

3. You should have /cases/plaso and /cases/processor folders already created. The account you are running Node-RED must have permission on /cases and its sub-folders.
4. You should have Timesketch and Log2timeline pre-installed on the same host as your Node-RED installation. This has been tested using TS and L2T's docker versions.
5. You should update the Log2timeline and Timesketch CLI parameters within the flow to meet your requirements.

How to install the workflow?
1. Download the workflow JSON and Import it using the Node-RED GUI.
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/NR_DFIRFlow.json

2. Update the "Timesketch CLI Params" with you TS credentials
3. Update the "Queue Zips" with the amount of ZIPs you would like to process at any given time
4. Hit Deploy Full!
5. Node-RED will watch for new files into the /cases/processor folder and it will kick off the flow

![Node-RED Flow in Action](https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/doco/NR1.png?raw=true)

Planned Improvements
~~1. Zip file integrity validation 
2. Dialog box to enter timesketch auth details so the token can be created at the start
3. Add flow branching to cater for E01 , Raw and VHDs
4. Notification of success and failures 


