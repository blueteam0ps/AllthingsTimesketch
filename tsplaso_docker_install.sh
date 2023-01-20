#!/bin/bash
# Description: This helper script will bring up Timesketch, Kibana (separate) and Plaso dockerised versions for rapid deployment. Further, it will set up InsaneTechnologies elastic pipelines so that relevant embedded fields can be extracted and mapped to fields in ES.
# Tested on Ubuntu 20.04 LTS Server Edition
# Created by Janantha Marasinghe
#
# Usage: sudo  echo -ne '\n' | ./tsplaso_docker_install.sh 
#
# Update APT database
sudo apt-get update

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


# Install all pre-required Linux packages
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg lsb-release unzip unrar docker-ce docker-ce-cli containerd.io python3-pip docker-compose -y

#Setting default user creds
USER1_NAME=jdoe
USER1_PASSWORD=$(openssl rand -base64 12)

cd /opt

# Download and install Timesketch
curl -s -O https://raw.githubusercontent.com/google/timesketch/master/contrib/deploy_timesketch.sh
chmod 755 deploy_timesketch.sh
./deploy_timesketch.sh
cd /opt/timesketch
 
# Download docker version of plaso
docker pull log2timeline/plaso
 
#add-apt-repository ppa:gift/stable -y
#apt-get update
#apt-get install plaso-tools -y

# Install Timesketch import client to assist with larger plaso uploads
pip3 install timesketch-import-client

# Download the latest tags file from blueteam0ps repo
wget -Nq https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/tags.yaml -O /opt/timesketch/etc/timesketch/tags.yaml

#Increase the CSRF token time limit
echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/etc/timesketch/timesketch.conf

sudo docker-compose up -d

# Create directories to hold the self-signed cert and the key 
sudo mkdir -p /opt/timesketch/ssl/certs
sudo mkdir -p /opt/timesketch/ssl/private
 
# Generate a local self-signed certificate for HTTPS operations
openssl req -x509 -out /opt/timesketch/ssl/certs/localhost.crt -keyout /opt/timesketch/ssl/private/localhost.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=localhost' -extensions EXT -config <( printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
  
#Restrict private key permissions
chmod 600 /opt/timesketch/ssl/private/localhost.key

# Download the custom nginx configuration
# Nginx modified to add the self-signed cert configuration
wget -Nq https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/nginx.conf -O /opt/timesketch/etc/nginx.conf

# Download the custom docker-compose configuration
# docker-compose modified to add the volume containing ssl cert and key for nginx
wget -Nq https://raw.githubusercontent.com/blueteam0ps/AllthingsTimesketch/master/docker-compose.yml -O /opt/timesketch/docker-compose.yml

# Start all docker containers to make the changes effective
sudo docker-compose down
sudo docker-compose up -d

# Giving few seconds for the docker instances to poweron 
sleep 15

# Create the first user account
sudo docker-compose exec timesketch-web tsctl add_user $USER1_NAME --password $USER1_PASSWORD

echo -e "************************************************\n"
printf "Timesketch User Details\n"
echo -e "************************************************\n"
printf "User name is $USER1_NAME and the password is $USER1_PASSWORD\n"
echo -e "************************************************\n"
echo -e "************************************************\n"
