#!/bin/bash

# variables and settings which will be used later in this script

# asks user for the netbox domain from which netbox should be accessed
read -p "Please type in the domain from which netbox should be accessed: " netbox_domain
netbox_domain="'$netbox_domain'"

# general updates 
apt update && apt upgrade -y

# installation of all required packages
apt install -y git redis-server python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev postgresql

### configuration of postgres db

# start and enable postgres service
systemctl start postgresql
systemctl enable postgresql

# creation of the netbox db
sudo -u postgres psql -c "CREATE DATABASE netbox;"

# Creates a postgres user netbox with a password and grant access to netbox database
sudo -u postgres psql -c "CREATE USER netbox WITH PASSWORD 'J5brHrAXFLQSif0K';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;"

mkdir -p /opt/

cd /opt/

git clone -b master --depth 1 https://github.com/netbox-community/netbox.git

adduser --system --group netbox

chown --recursive netbox /opt/netbox/netbox/media/

cd /opt/netbox/netbox/netbox/

cp configuration_example.py configuration.py

# path to config file
config_file="configuration.py"

# edit lines in netbox configuration file
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[$netbox_domain\]/g" "$config_file"


# username and password
db_user="netbox"
db_password="J5brHrAXFLQSif0K"

# edit lines in netbox configuration file
sed -i "0,/'USER': ''/{s//'USER': '$db_user'/}" "$config_file"
sed -i "0,/'PASSWORD': ''/{s//'PASSWORD': '$db_password'/}" "$config_file"


# generates the secret key used for the netbox instance
secret_key=$(python3 ../generate_secret_key.py)

# edits the line in configuration.py and inserts the secret key
sed -i "s/SECRET_KEY = ''/SECRET_KEY = '$secret_key'/g" "$config_file"

/opt/netbox/upgrade.sh

source /opt/netbox/venv/bin/activate

cd /opt/netbox/netbox

python3 manage.py createsuperuser

ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping


cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py


cp -v /opt/netbox/contrib/*.service /etc/systemd/system/

systemctl daemon-reload

systemctl start netbox netbox-rq

systemctl enable netbox netbox-rq

systemctl status netbox.service


openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/netbox.key \
-out /etc/ssl/certs/netbox.crt

apt install -y apache2

cp /opt/netbox/contrib/apache.conf /etc/apache2/sites-available/netbox.conf


a2enmod ssl proxy proxy_http headers
a2ensite netbox
systemctl restart apache2