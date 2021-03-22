# AllthingsTimeSketch

<h1>Purpose</h1>
This repository contains helper/timesaver scripts/queries related to Timesketch and Plaso.

<h2>Timesketch and Plaso Auto Install & Configuration Script(Recommended)</h2>
This script will automatically get the latest docker version of Timesketch and Plaso. It will download the latest tagger file from this repo as well. Then it creates the first user account in Timesketch.

<b>Usage</b>
Note: You need to be running Ubuntu 20.04 LTS for this.

wget https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tsplaso_docker_install.sh

chmod a+x /tsplaso_docker_install.sh
./tsplaso_docker_install.sh

<h2>Timesketch and Plaso Auto Install & Configuration Script(Old method)</h2>
This script will automatically install Timesketch (version available via pip) and Plaso (apt repo). Nginx proxy will be installed
This script has only been tested on Ubuntu 18.04 LTS. 

<b>Usage</b>
git clone the repo
chmod a+x deployts.sh
That is it. :)

<b>Tags file for faster triage and aid your analysis</b>
.Use the following tags file to get most out of TS
https://github.com/blueteam0ps/AllthingsTimesketch/blob/master/tags.yaml
