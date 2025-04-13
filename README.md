#  Docker & Docker Compose Installation Scripts

This repository provides two simple Bash scripts to install:

-  Docker Engine  
-  Docker Compose (CLI plugin)

These scripts support **Ubuntu/Debian/Kali/RHEL**

---

##  Files

### `Installing_Docker_Through_Script.sh`

This script installs the latest version of **Docker Engine** on your system.

### `Installing_Docker-Compose_Through_Script.sh`

This script installs the **Docker Compose CLI plugin**, allowing you to run `docker compose` commands (note: no hyphen).

### `Installing_Docker_And_Docker_Compose_On_Kali.sh`

This script installs the latest version of **Docker Engine** and **Docker Compose CLI plugin** for kali linux.

---

##  Prerequisites

- A supported Linux OS:
  - Ubuntu / Debian / KALI / RHEL
- `curl` and `sudo` privileges
- Internet access

---

##  How to Use

### 1. Clone the Repository or Download the Scripts

```bash
git clone https://github.com/gmouheb/Installing_Docker_and_Docker_Compose_Through_Script.git
#giving execution permissions
sudo chmod +x -R docker-install-scripts
cd docker-install-scripts
# to execute it use:
source Installing_Docker_Through_Script.sh
source Installing_Docker-Compose_Through_Script.sh
or simply use :
./Installing_Docker-Compose_Through_Script.sh
./Installing_Docker_Through_Script.sh
# For kali linux use
source Installing_Docer_And_Docker_Compose_On_Kali.sh
