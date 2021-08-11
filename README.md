# AllthingsTimesketch

<h1>Purpose</h1>
This repository contains helper/timesaver scripts/queries related to Timesketch.

<h2>Timesketch and Plaso Auto Install & Configuration Script(Recommended)</h2>
This script will automatically<br/>
 - gets the latest docker version of Timesketch, Plaso<br/>
 - configures Elastic Post processing pipelines (https://github.com/InsaneTechnologies/elasticsearch-plaso-pipelines)<br/>
 - downloads the latest tagger file from this repo<br/>
 - creates the first user account in Timesketch.<br/>

OPTIONAL - Bulk watch & process script be executed on the TS server to watch for incoming triage ZIP files and autorun unzip, l2t and timesketch ingestion tasks. https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/l2t_ts_watcher.sh

<b>Usage</b>
Note: You need to be running Ubuntu 20.04 LTS for this.

wget https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh

chmod a+x ./tsplaso_docker_install.sh

sudo ./tsplaso_docker_install.sh

<h2>Timesketch and Plaso Auto Install & Configuration Script(Old method)</h2>
This script will automatically install Timesketch (version available via pip) and Plaso (apt repo). Nginx proxy will be installed
This script has only been tested on Ubuntu 18.04 LTS. 

<b>Usage</b>
git clone the repo
chmod a+x deployts.sh
That is it. :)

<b>Tags file for faster triage</b>
Use the following tags file to get most out of TS (It is already part of the tsplaso_docker_install.sh script
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/tags.yaml

<h2>Customised docker-compose file</h2>
The customised docker-compose file can be used in instances where a separate Dockerised Kibana is required. Further, the ES docker config was updated to have the ES ports exposed to the host. Please ensure the host based firewall is configured to lock down the ports in production environment.

<h2>Bulk Upload Automated Handling</h2>
Following shell script can be used on the processing server to automate the following tasks once a zip file gets uploaded.
This script is based on https://github.com/ReconInfoSec/velociraptor-to-timesketch and https://github.com/mpilking/for608-public.
1. Validate that the uploaded is a zip file and extracts to a unique directory
2. Execute Log2timeline workflow on top of the data set
3. Execute Timesketch workflow taking the newly generated Plaso file
4. Remove the ZIP and extracted directory 
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/l2t_ts_watcher.sh
