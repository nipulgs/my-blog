---
layout: post
title:  "Fail2Ban Installation, Customization & Work Process"
date:   2023-07-13 12:00:00 +0530
tags: [Fail2Ban, Security, Ubuntu]
---

# Fail2Ban Installation, Customization & Work Process

## Introduction

Fail2Ban is a log-parsing security tool that helps protect your server against brute-force attacks by banning malicious IPs dynamically.

## Prerequisites

* Linux server (Ubuntu, Debian, CentOS, etc.)
* Root or sudo privileges
* Basic knowledge of SSH

## Installation Steps

### Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Fail2Ban

```bash
sudo apt install fail2ban -y
```

### Step 3: Enable and Start Service

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Step 4: Verify Status

```bash
sudo systemctl status fail2ban
```

## Basic Configuration

### Config File Location

* Main: `/etc/fail2ban/jail.conf`
* Local override: `/etc/fail2ban/jail.local`

**Important:** Never edit `jail.conf` directly. Create a local override:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

### Edit Ban Settings

Open `jail.local`:

```bash
sudo nano /etc/fail2ban/jail.local
```

Example:

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8
```

## Customization

### SSH Jail Example

Make sure the SSH jail is enabled:

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
```

### Restart Fail2Ban

```bash
sudo systemctl restart fail2ban
```

## Work Process / Management

* Check Status:

  ```bash
  sudo fail2ban-client status
  sudo fail2ban-client status sshd
  ```

* Unban IP:

  ```bash
  sudo fail2ban-client set sshd unbanip <IP_ADDRESS>
  ```

* Restart/Stop/Start:

  ```bash
  sudo systemctl restart fail2ban
  sudo systemctl stop fail2ban
  sudo systemctl start fail2ban
  ```

## Best Practices

* Backup `jail.local` before editing.
* Monitor `/var/log/fail2ban.log`.
* Test new jails to verify correct behavior.

## References

* [Fail2Ban Official Docs](https://www.fail2ban.org/wiki/index.php/Main_Page)

---

**End of Guide**
