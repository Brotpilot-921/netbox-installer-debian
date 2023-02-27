#!/bin/bash

if systemctl list-unit-files | grep -q "netbox-rq.service\|netbox.service"; then
    echo "Looks like there was a NetBox allready in the past, can only start on a fresh system."
    echo "The installer will quit now."
    exit 1
else
    echo "netbox-rq.service and netbox.service are not running, starting..."
    
    # variables
    netbox_install_logfile = "netbox_installation.log"
    
    # variables and settings which will be used later in this script

    # name of config file
    config_file="configuration.py"

    # asks user for the netbox domain from which netbox should be accessed
    read -p "Please type in the domain from which netbox should be accessed: " netbox_domain
    netbox_domain="'$netbox_domain'"

    # asks user for postgres db user
    read -p "Please define a postgres user: " postgres_db_user

    password_match=false

    while [ "$password_match" = false ]
    do
    # Eingabeaufforderung für das Passwort
    echo "Please define a postgres user password for the created db user $postgres_db_user: "
    read -s password1

    echo "Please re-enter your password: "
    read -s password2

    # Vergleich der Passwörter
    if [ "$password1" = "$password2" ]; then
        echo "Passwords match."
        # Das Passwort wird in der Variablen "password" gespeichert
        postgres_db_user_password="$password1"
        password_match=true
    else
        echo "Passwords do not match. Please try again."
    fi
    done

    # general updates
    echo "Updating the system"
    "apt update && apt upgrade -y" &>> $netbox_install_logfile

    # installation of all required packages
    echo "Installing all required packages"
    "apt install -y git redis-server python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev postgresql apache2" &>> $netbox_install_logfile

    ### configuration of postgres db

    # start and enable postgres service
    systemctl start postgresql && systemctl enable postgresql

    # creation of the netbox db
    sudo -u postgres psql -c "CREATE DATABASE netbox;"
    # Creates a postgres user netbox with a password and grant access to netbox database
    sudo -u postgres psql -c "CREATE USER $postgres_db_user WITH PASSWORD '$postgres_db_user_password';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE netbox TO $postgres_db_user;"

    mkdir -p /opt/

    cd /opt/

    git clone -b master --depth 1 https://github.com/netbox-community/netbox.git

    adduser --system --group netbox

    chown --recursive netbox /opt/netbox/netbox/media/

    cd /opt/netbox/netbox/netbox/

    cp configuration_example.py configuration.py

    # edit line in netbox configuration file
    sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[$netbox_domain\]/g" "$config_file"
    # edit line in netbox configuration file
    sed -i "0,/'USER': ''/{s//'USER': '$postgres_db_user'/}" "$config_file"
    # edit line in netbox configuration file
    sed -i "0,/'PASSWORD': ''/{s//'PASSWORD': '$postgres_db_user_password'/}" "$config_file"
    # generates the secret key used for the netbox instance
    secret_key=$(python3 ../generate_secret_key.py)
    # edits the line in configuration.py and inserts the secret key
    sed -i "s/SECRET_KEY = ''/SECRET_KEY = '$secret_key'/g" "$config_file"

    #Start the actual installation of NetBox
    /opt/netbox/upgrade.sh

    source /opt/netbox/venv/bin/activate

    cd /opt/netbox/netbox

    # Creates NetBox admin
    python3 manage.py createsuperuser

    ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping


    cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py


    cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl start netbox netbox-rq && systemctl enable netbox netbox-rq

    #Apache2 configuration

    # Generating certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/netbox.key \
    -out /etc/ssl/certs/netbox.crt

    # Copy NetBox apache2 config
    cp /opt/netbox/contrib/apache.conf /etc/apache2/sites-available/netbox.conf
    # Activates apache2 modules
    a2enmod ssl proxy proxy_http headers
    # Enables site
    a2ensite netbox
    # Restarts apache2 to take affect of the config 
    systemctl restart apache2
fi