# AllthingsTimesketch

<h1>Purpose</h1>
This repository contains helper/timesaver scripts/queries related to Timesketch.

<h2>Timesketch and Plaso Auto Install & Configuration Script(Recommended)</h2>
This script will automatically<br/>
 - gets the latest docker version of Timesketch, Plaso<br/>
 - configures Elastic Post processing pipelines (https://github.com/InsaneTechnologies/elasticsearch-plaso-pipelines)<br/>
 - downloads the latest tagger file from this repo<br/>
 - creates the first user account in Timesketch.<br/>

OPTIONAL - 
Node-RED based bulk triage processing workflow

Bulk watch & process script be executed on the TS server to watch for incoming triage ZIP files and autorun unzip, l2t and timesketch ingestion tasks. https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/l2t_ts_watcher.sh

<b>Usage</b>
Note: You need to be running Ubuntu 20.04 LTS for this.

wget https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh

chmod a+x ./tsplaso_docker_install.sh

sudo ./tsplaso_docker_install.sh

<b>Tags file for faster triage</b>
Use the following tags file to get most out of TS (It is already part of the tsplaso_docker_install.sh script
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/tags.yaml

<h2>Customised docker-compose file</h2>
The customised docker-compose file can be used in instances where a separate Dockerised Kibana is required. Further, the ES docker config was updated to have the ES ports exposed to the host. Please ensure the host based firewall is configured to lock down the ports in production environment.

<h1> Automating DFIR Triage Processing Workflow</h1>
My inspiration for the following mini projects were from the work carried by Eric Capuano (AWS DFIR Automation) and knowledge sharing sessions with Mike Pilkington. Special thanks to Sam Machin @https://github.com/sammachin for his continous support with troubleshooting Node-RED workflow issues with me. 

<h2>Node-RED Automation to handle triage processing</h2>
Node-RED is a browser based flow editor which provides an easier way to achieve automation. I've created an automation flow where the flow will watch for ZIP files in /cases/processor directory. When new triage zip files get uploaded (Tested with CyLR zips) it will automatically unzip into a unique folder, parses it with Log2timeline and ingests into Timesketch using Timesketch-Importer script. It has the ability to queue up zip files for processing. This was you can control how many zips gets processed at a point in time. 

Pre-requisites
---------------------
1. Install Node-RED using the instructions given at https://nodered.org/docs/getting-started/. I've tested this on Ubuntu 20.04 (https://nodered.org/docs/getting-started/raspberrypi)
2. This automation depends on the following additonal nodes. I recommend installing it directly via the GUI -> Manage Pallette -> Install after you install Node-RED

-node-red-contrib-fs
-node-red-contrib-fs-ops
-node-red-contrib-simple-queue
-node-red-contrib-watchdirectory
-node-red-contrib-zip

3. You should have /cases/plaso and /cases/processor folders already created. The account you are running Node-RED must have permission on /cases and its sub-folders.
4. You should have Timesketch and Log2timeline pre-installed on the same host as your Node-RED installation. This has been tested using TS and L2T's docker versions.

How to install the workflow?
1. Download the workflow JSON and Import it using the Node-RED GUI.
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/NR_DFIRFlow.json

2. Update the "Timesketch CLI Params" with you TS credentials
3. Update the "Queue Zips" with the amount of ZIPs you would like to process at any given time
4. Hit Deploy Full!
5. Node-RED will watch for new files into the /cases/processor folder and it will kick off the flow

![Node-RED Flow in Action](https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/doco/NR1.png?raw=true)

<h2>Bulk Upload Automated Handling</h2>
Following shell script can be used on the processing server to automate the following tasks once a zip file gets uploaded.
This script is inspired by https://github.com/ReconInfoSec/velociraptor-to-timesketch and https://github.com/mpilking/for608-public.
1. Validate that the uploaded is a zip file and extracts to a unique directory
2. Execute Log2timeline workflow on top of the data set
3. Execute Timesketch workflow taking the newly generated Plaso file
4. Remove the ZIP and extracted directory 
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/l2t_ts_watcher.sh
