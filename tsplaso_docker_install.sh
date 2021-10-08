#!/bin/bash
# Description: This helper script will bring up Timesketch, Kibana (separate) and Plaso dockerised versions for rapid deployment. Further, it will set up InsaneTechnologies elastic pipelines so that relevant embedded fields can be extracted and mapped to fields in ES.
# Tested on Ubuntu 20.04 LTS Server Edition
# Created by Janantha Marasinghe
#
# Usage: sudo ./tsplaso_docker_install.sh 
#

# Update APT database
sudo apt-get update

# Install Docker CE
 apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

 apt-get update
 apt-get install docker-ce docker-ce-cli containerd.io -y
 apt-get install python3-pip -y

 #Setting default user creds
 USER1_NAME=jdoe
 USER1_PASSWORD=$(openssl rand -base64 12)

 # Install Docker Compose
 apt install docker-compose -y
 cd /opt

 # Download and install Timesketch
 curl -s -O https://raw.githubusercontent.com/google/timesketch/master/contrib/deploy_timesketch.sh
 chmod 755 deploy_timesketch.sh
 ./deploy_timesketch.sh
 cd /opt/timesketch
 
  # Custom Docker-Compose file to include a separate Kibana instance and tsylink attachment
 curl -s -O https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/docker-compose.yml
 
 # Create a user-defined docker bridge network 
 docker network create tsylink

 docker-compose up -d

 # Download docker version of plaso
 #docker pull log2timeline/plaso
 
 add-apt-repository ppa:gift/stable -y
 apt-get update
 apt-get install plaso-tools -y

 # Install Timesketch import client to assist with larger plaso uploads
 pip3 install timesketch-import-client

  # Download the latest tags file from blueteam0ps repo
 wget -N https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tags.yaml -O /opt/timesketch/etc/timesketch/tags.yaml

 sudo docker-compose exec timesketch-web tsctl add_user --username $USER1_NAME --password $USER1_PASSWORD

 #Increasing the CSRF token time limit
 echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/etc/timesketch/timesketch.conf

 #Restart Timesketch web app docker so that it gets the latest config
 docker restart timesketch_timesketch-web_1
 
 cd /opt/
 #Downloading the Plaso Filter File 
 curl -s -O https://raw.githubusercontent.com/log2timeline/plaso/main/data/filter_windows.yaml
 
 ###NOTE - Event drops observed when the pipelines were used so this requires further investigation.
 #Insane Technologies pipelines https://github.com/InsaneTechnologies/elasticsearch-plaso-pipelines
 #git clone https://github.com/blueteam0ps/elasticsearch-plaso-pipelines.git
 #cd elasticsearch-plaso-pipelines/
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso-olecf?pretty -d @plaso-olecf.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso-evidenceof?pretty -d @plaso-evidenceof.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso-geoip?pretty -d @plaso-geoip.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso-winevt?pretty -d @plaso-winevt.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso-normalise?pretty -d @plaso-normalise.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/iis-normalise?pretty -d @iis-normalise.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -s -X PUT -H content-type:application/json http://localhost:9200/_ingest/pipeline/plaso?pretty -d @plaso.json | tee /dev/stderr | grep -sq '"acknowledged" : true'
 #curl -X PUT "http://localhost:9200/_template/insaneplaso" -H 'Content-Type: application/json' -d'{  "index_patterns": [    "o365-*",    "plaso-*",    "dfir-*",    "iis-*",    "siem*"  ],  "order": 0,  "settings": {    "index": {      "default_pipeline": "plaso"    }  },  "mappings": {},  "aliases": {}}'
 
 #Running Timesketch tagger on large number of timelines can exceed the 500 scroll context limit. This causes errors. A fix was to increase the scroll context count
 curl -X PUT "http://localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'{ "persistent" : { "search.max_open_scroll_context": 1024}, "transient": {"search.max_open_scroll_context": 1024}}'

 echo -e "************************************************\n"
 printf "Timesketch User Details\n"
 echo -e "************************************************\n"
 printf "User name is $USER1_NAME and the password is $USER1_PASSWORD\n"
 echo -e "************************************************\n"
 echo -e "************************************************\n"
