# AllthingsTimesketch
# Purpose
Processing of host triage packages is always a challenge when dealing with incidents involving large number of hosts. 
This repository contains 
- a build script to install and configure Timesketch and associated services
- a workflow built using NodeRED to automate handling of triage archives, processing triage archives using log2timeline and ingestion into Timesketch.
- a custom Timesketch tagger file that has a curated list of pre-built queries (mapped to MITRE ATT&CK were possible). It can be used to quickly identify initial pivot points and get contextual information during investigations. 

# Basic Information
This section provides a brief overview of the automation setup and how things are configured.

#### Node-RED Workflow to handle triage archive processing
Node-RED is a browser based flow editor which provides an easier way to achieve automation. 
[NR_DFIR](https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/NR_DFIRFlow.json) is an automation workflow where the flow will watch for archive files created at /cases/processor directory. When new triage archive files get created (Tested with CyLR and KAPE zips) it will run an integrity check and decompress them to unique folders, parses it with Log2timeline and ingests into Timesketch. It has the ability to queue up archive files for processing. This way you have the option to control how many archive files gets processed at any given point in time. 

The Node-RED workflow contains three flows
1. #### Triage Artefact Processor
This is the main workflow for the automation. It consists of archive validation checks, log2timeline processing and ingestion to Timesketch.
![Node-RED Flow in Action](https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/doco/NR1.png?raw=true)

2. #### Detect Archive & Integrity Check
This flow is used to detect the type of archive and then run an integrity check on the archive
![Node-RED Flow in Action](https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/doco/DetectArchive.jpg?raw=true)

3. #### Decompress Archive
This flow is used to detect the type of the archive and perform the relevant decompression action
![Node-RED Flow in Action](https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/doco/Decompress.jpg?raw=true)

### Timesketch
[Timesketch](https://timesketch.org/) is a core component of this project. The uses the docker version of Timesketch and Log2timeline.
[tsplaso_docker_install.sh script](https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh) can be used to simplify install and configuration.
Note: This script was tested on the latest Ubuntu 20.04.5 Server Edition.

#### Usage instructions for the script
##IMPORTANT - This bash script uses a custom version of nginx.conf and docker-compose.yml
wget https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh
chmod a+x ./tsplaso_docker_install.sh
sudo ./tsplaso_docker_install.sh

### Tagging file for Timesketch
A [tagging file](https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tags.yaml) is provided as part of this repository. It is used to get most out of Timesketch (It is already part of the tsplaso_docker_install.sh script


## Pre-requisites
---------------------
1. Install and configure Timesketch and Log2timeline. [tsplaso_docker_install.sh script](https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh) can assist with that. 
IMPORTANT!!! - tsplaso_docker_install.sh generates a self-signed certificate for the hostname 'localhost' and sets the nginx proxy configuration to use it.
2. Install Node-RED using the instructions given at https://nodered.org/docs/getting-started/. This has been tested on Ubuntu 20.04.5 LTS (https://nodered.org/docs/getting-started/raspberrypi)
3. Pre-install any archiving tools on your host (i.e. unrar, 7z , unzip)
4. This automation depends on the following additonal nodes. I recommend installing it directly via the GUI -> Manage Pallette
- node-red-contrib-fs
- node-red-contrib-fs-ops
- node-red-contrib-simple-queue
- node-red-contrib-watchdirectory
5. You should have /cases/plaso and /cases/processor folders already created. The account you are running Node-RED must have read and write permissions on /cases and its sub-folders.
6. You should have Timesketch and Log2timeline pre-installed on the same host as your Node-RED installation.
7. You should update the Log2timeline and Timesketch CLI parameters within the flow to meet your requirements.

## How to setup the workflow?
1. Download the workflow JSON and Import it using the Node-RED GUI.
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/NR_DFIRFlow.json

2. Update the "Timesketch CLI Params" with you Timesketch credentials
3. Update the "Queue Zips" with the amount of archives you would like to process at any given time
4. Hit Deploy Full!
5. Node-RED will watch for new files into the /cases/processor folder and it will kick off the flow

## Planned Improvements
1. Dialog box to enter timesketch auth details so the token can be created at the start interactively
2. Add flow branching to cater for E01 , Raw and VHDs
3. Notification of processing workflow via Slack

#### Automating DFIR Triage Processing Workflow
My inspiration for the workflow was from the work carried by Eric Capuano (AWS DFIR Automation) and knowledge sharing sessions with Mike Pilkington. Special thanks to Sam Machin (https://github.com/sammachin) for his continous support with troubleshooting Node-RED workflow issues with me. 
