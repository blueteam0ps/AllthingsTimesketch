#!/bin/bash
#This script automates the installation and configuration of Timesketch and Plaso.
#Nginx is used to proxy requests via SSL to the local timesketch port. If you have multiple web based tools running on a host, then you can change the NGINX config easily using the 'location' construct.
#Plaso - https://github.com/log2timeline/plaso
#Timesketch - https://github.com/google/timesketch
#Developed by Janantha Marasinghe
#Last updated on 13/09/2020
#THIS SCRIPT WAS TESTED ON UBUNTU 18.04 LTS ONLY!

#Generating Postgrey SQL Secrety keys and the DB user password
SECRET_KEY=$(openssl rand -base64 32)
DBUSR_PASS=$(openssl rand -base64 32)

#HostIP
IP=$(hostname -I)

#Setting default user creds
USER1_NAME=jdoe
USER1_PASSWORD=$(openssl rand -base64 12)

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
add-apt-repository ppa:gift/stable -y
apt-get update

apt-get install elasticsearch postgresql python3-pip python3-dev libffi-dev python3-psycopg2 plaso-tools nginx -y
pip3 install redis
#Upgrading Redis post install to fix an issue with running l2t
pip3 install redis --upgrade 

/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl start elasticsearch.service
/bin/systemctl enable nginx
/bin/systemctl start nginx

#Setting up Postgrey SQL
echo "local   all             timesketch                              md5" >> /etc/postgresql/10/main/pg_hba.conf
/etc/init.d/postgresql restart

sudo -u postgres psql --command "CREATE USER timesketch WITH PASSWORD '${DBUSR_PASS}';"
sudo -u postgres psql --command "CREATE database timesketch;"
sudo -u postgres psql --command "GRANT ALL PRIVILEGES ON DATABASE timesketch TO timesketch;"

#Setting up Timesketch
pip3 install timesketch
mkdir /etc/timesketch
cp /usr/local/share/timesketch/timesketch.conf /etc/timesketch/
chmod 600 /etc/timesketch/timesketch.conf

#Adding the SECRET_KEY, DB user and password to Timesketch config
sed -i "s|<KEY_GOES_HERE>|${SECRET_KEY}|g" /etc/timesketch/timesketch.conf
sed -i "s|<USERNAME>|timesketch|g" /etc/timesketch/timesketch.conf
sed -i "s|<PASSWORD>|${DBUSR_PASS}|g" /etc/timesketch/timesketch.conf

#Adding Timesketch to autostart when OS boots
printf "#!/bin/bash \n" > /etc/init.d/tsstart
printf "nohup tsctl runserver -h localhost -p 5000 2>&1 &" >> /etc/init.d/tsstart
chmod 755 /etc/init.d/tsstart
ln -s /etc/init.d/tsstart /etc/rc3.d/S99tsstart

#Creating a self-signed SSL Certificate for NGINX
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=MA/L=Pluto/O=Dis/CN=ts.local" -keyout /etc/nginx/ts.key -out /etc/nginx/ts.crt

#Setting permissions for the key and cert
chmod 644 /etc/nginx/ts.crt
chmod 600 /etc/nginx/ts.key

#Pushing the reverse proxy configuration to Production
unlink /etc/nginx/sites-enabled/default
cp tsproxy /etc/nginx/sites-available
ln -s /etc/nginx/sites-available/tsproxy /etc/nginx/sites-enabled/tsproxy
/bin/systemctl restart nginx

#Enable Ubuntu Firewall
ufw allow 22,80,443/tcp
ufw --force enable

tsctl add_user --username $USER1_NAME --password $USER1_PASSWORD

nohup tsctl runserver -h localhost -p 5000 2>&1 &

echo -e "************************************************\n"
printf "Timesketch User Details\n"
echo -e "************************************************\n"
printf "User name is $USER1_NAME and the password is $USER1_PASSWORD\n"
echo -e "************************************************\n"
echo -e "************************************************\n"
printf "All done you can now access Timesketch using http://localhost OR http://$IP\n"

#Clearing console history
history -c 
