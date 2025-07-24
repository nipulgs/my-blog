---
layout: post
title:  "ERPNext Installation on Ubuntu Guide"
date:   2025-07-15 12:00:00 +0530
tags: [ERPNext, Installation, ERP]
---

# ERPNext Installation on Ubuntu Guide


A step-by-step guide for installing **NextERP / ERPNext** on **Ubuntu 20.04 LTS** (or similar).  
*If you meant a different ERP, share its official link and I’ll adapt this!*

---

## Prerequisites

- Ubuntu Server (20.04 LTS recommended)  
- Non-root user with `sudo` privileges  
- Basic packages: `git`, `curl`, `python3`, `pip`, `node`, `npm`  
- MariaDB or MySQL  
- Redis

---

## Update your system

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git curl -y
```

## Install Python & dependencies
```bash
sudo apt install python3-dev python3-pip python3-venv -y
sudo apt install software-properties-common -y
```

## Install Node.js & Yarn
```bash
# Install Node.js (18.x)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E ```bash -
sudo apt install -y nodejs

# Install Yarn globally
sudo npm install -g yarn
```

## Install & configure MariaDB
```bash
sudo apt install mariadb-server mariadb-client -y
sudo mysql_secure_installation
```

Create database & user
```sql
sudo mysql -u root -p

-- In MariaDB shell:
CREATE DATABASE nexterp;
CREATE USER 'nexterp_user'@'localhost' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON nexterp.* TO 'nexterp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## Install Redis
```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## Install Frappe Bench CLI
```bash
sudo pip3 install frappe-bench
```

## Create a new Bench
```bash
bench init nexterp-bench --frappe-branch version-15
cd nexterp-bench
```

## Create a new site
```bash
bench new-site nexterp.local
```

Provide DB credentials when prompted.


## Get the ERPNext app
```bash
bench get-app erpnext --branch version-15
```


## Install the app on your site
```bash
bench --site nexterp.local install-app erpnext
```


## Start the server
```bash
bench start
```

`Access at: http://localhost:8000`


## You’re done!

🎉 NextERP / ERPNext is now running!
