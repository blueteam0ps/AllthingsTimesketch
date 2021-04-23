#!/bin/bash
# Description: This helper script will bring up Timesketch and Plaso dockerised versions for rapid deployment.
# Tested on Ubuntu 20.04 LTS Server
# By J Marasinghe

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
 docker-compose up -d

 # Download docker version of plaso
 docker pull log2timeline/plaso

 # Install Timesketch import client to assist with larger plaso uploads
 pip3 install timesketch-import-client

  # Download the latest tags file from blueteam0ps repo
  wget -N https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tags.yaml -O /opt/timesketch/etc/timesketch/tags.yaml

 sudo docker-compose exec timesketch-web tsctl add_user --username $USER1_NAME --password $USER1_PASSWORD

 #Increasing the CSRF token time limit
 echo "WTF_CSRF_TIME_LIMIT = 3600" >> /opt/timesketch/etc/timesketch/timesketch.conf

 #Restart Timesketch web app docker so that it gets the latest config
 docker restart timesketch_timesketch-web_1

 echo -e "************************************************\n"
 printf "Timesketch User Details\n"
 echo -e "************************************************\n"
 printf "User name is $USER1_NAME and the password is $USER1_PASSWORD\n"
 echo -e "************************************************\n"
 echo -e "************************************************\n"
