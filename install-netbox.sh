#!/bin/bash

## -------- Installation und Konfiguration Postgres DB

# Paketquellen aktualisieren
sudo apt update

#Postgres installieren
sudo apt install -y postgresql

#Dienst starten
sudo systemctl start postgresql
sudo systemctl enable postgresql

# PostgreSQL-Datenbank erstellen
sudo -u postgres psql -c "CREATE DATABASE netbox;"

# Benutzer erstellen und Berechtigungen erteilen
sudo -u postgres psql -c "CREATE USER netbox WITH PASSWORD 'J5brHrAXFLQSif0K';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;"

## -------- Installation Redis

sudo apt install -y redis-server


## -------- Installation NetBox Core

sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev

sudo mkdir -p /opt/

cd /opt/

sudo apt install -y git

sudo git clone -b master --depth 1 https://github.com/netbox-community/netbox.git

sudo adduser --system --group netbox

sudo chown --recursive netbox /opt/netbox/netbox/media/

cd /opt/netbox/netbox/netbox/

sudo cp configuration_example.py configuration.py

# Pfad zur Konfigurationsdatei
config_file="configuration.py"

# Benutzer zur Eingabe des Textes auffordern und in einer Variable zwischenspeichern
read -p "Geben Sie den Text ein, der in der Liste der zulässigen Hosts eingetragen werden soll: " allowed_host_text
allowed_host_text="'$allowed_host_text'"

# Zeile in der Konfigurationsdatei finden und bearbeiten
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[$allowed_host_text\]/g" "$config_file"



# Pfad zur Konfigurationsdatei
config_file="configuration.py"

# Benutzername und Passwort setzen
db_user="netbox"
db_password="J5brHrAXFLQSif0K"

# Zeilen in der Konfigurationsdatei finden und bearbeiten
sed -i "0,/'USER': ''/{s//'USER': '$db_user'/}" "$config_file"
sed -i "0,/'PASSWORD': ''/{s//'PASSWORD': '$db_password'/}" "$config_file"




# Pfad zur Konfigurationsdatei
config_file="configuration.py"

# Secret Key generieren und in einer Variable zwischenspeichern
secret_key=$(python3 ../generate_secret_key.py)

# Zeile in der Konfigurationsdatei finden und bearbeiten
sed -i "s/SECRET_KEY = ''/SECRET_KEY = '$secret_key'/g" "$config_file"

sudo /opt/netbox/upgrade.sh

source /opt/netbox/venv/bin/activate

cd /opt/netbox/netbox

python3 manage.py createsuperuser

sudo ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping


sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py


sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl start netbox netbox-rq

sudo systemctl enable netbox netbox-rq

systemctl status netbox.service


sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/netbox.key \
-out /etc/ssl/certs/netbox.crt

sudo apt install -y apache2

sudo cp /opt/netbox/contrib/apache.conf /etc/apache2/sites-available/netbox.conf


sudo a2enmod ssl proxy proxy_http headers
sudo a2ensite netbox
sudo systemctl restart apache2