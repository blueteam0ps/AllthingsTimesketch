# AllthingsTimesketch

<h1>Purpose</h1>
This repository contains helper/timesaver scripts/queries related to Timesketch.

<h2>Timesketch and Plaso Auto Install & Configuration Script(Recommended)</h2>
This script will automatically get the latest docker version of Timesketch, Plaso, Configures Elastic Post processing pipelines (https://github.com/InsaneTechnologies/elasticsearch-plaso-pipelines). It will download the latest tagger file from this repo as well. Then it creates the first user account in Timesketch.

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
