# NetBox Installer for Debian 🐧

⚠️ Attention
This script should only be used on a new and fresh system as it **could** break other installed applications.

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Notes](#notes)
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

This script is tested under Debian 11 Bulleseye.
For furthure installation and upgrade instructions, visit https://docs.netbox.dev/en/stable/installation/.


## Roadmap <a name = "roadmap"></a>

Plans currently in development:
- Configuration of multiple netbox domains

Plans for future:
- Add support for nginx (currently only apache2)
- Add support for other certificates (currently only self-signed certs)
- Add more error detection
- Improving file path handeling