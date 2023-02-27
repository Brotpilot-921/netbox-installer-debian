# NetBox Installer Debian

⚠️ Attention <br>
This script is in early stage and not ready for production usage.<br>
Things, that this script can't do:
- detect errors
- can detect when the user types in multiple netbox domains
- work with absolute file paths


Plans for future:<br>
- add support for nginx (currently only apache2)
- add support for other certificates (currently only self-signed certs)
## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

This script creates a fully functional NetBox instance on a Debian system.

## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites
```shell
# Update packages
sudo apt update
# Install git
sudo apt install git
#Clone GitHub repo
git clone https://github.com/Brotpilot-921/netbox-installer-debian.git
# change folder 
cd netbox-installer-debian
# Make file executable
chmod +x install-netbox.sh
```

### Installing
```shell
sudo ./install-netbox.sh
```

## Usage <a name = "usage"></a>

Add notes about how to use the system.
