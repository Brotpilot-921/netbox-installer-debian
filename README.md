# NetBox Installer for Debian

⚠️ Attention<br>
This script should only be used on a new and fresh system as it **could** break other installed applications.<br>

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Notes](#notes)
- [Usage](#usage)
- [Roadmap](#roadmap)

## About <a name = "about"></a>

This script creates a fully functional NetBox instance on a Debian system.

## Getting Started <a name = "getting_started"></a>

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
chmod +x netbox-install.sh
```

### Installing
```shell
sudo ./install-netbox.sh
```

## Notes <a name = "notes"></a>

This script is tested under Debian 11 Bulleseye.<br>
For furthure 


## Usage <a name = "usage"></a>

Things, that this script can't do
- work with absolute file paths

## Roadmap <a name = "roadmap"></a>

Plans for future:
- add support for nginx (currently only apache2)
- add support for other certificates (currently only self-signed certs)
- add more error detection
- configuration of multiple netbox domains