---
layout: post
title:  "Koha Performance Tuning Guide"
date:   2025-09-12 12:00:00 +0530
tags: [Performance Tuning, koha, Apache Prefork, Plack]
---

# Koha Performance Tuning Guide

This guide provides recommended settings for Koha installations using **Apache Prefork** and **Plack**, based on server size, RAM, CPU cores, and expected users. It also includes steps to restart services, caching recommendations, and performance testing.

---

## 1. Apache `mpm_prefork.conf`

Path: `/etc/apache2/mods-available/mpm_prefork.conf`

### Small Server (≤4GB RAM, 2 cores, <50 users)

```apache
<IfModule mpm_prefork_module>
    StartServers            2
    MinSpareServers         2
    MaxSpareServers         4
    MaxRequestWorkers       50
    MaxConnectionsPerChild  2000
</IfModule>
```
### Medium Server (8–16GB RAM, 4–8 cores, 100–200 users)
```apache
<IfModule mpm_prefork_module>
    StartServers            3
    MinSpareServers         3
    MaxSpareServers         6
    MaxRequestWorkers       120
    MaxConnectionsPerChild  5000
</IfModule>
```
### Large Server (32GB+ RAM, 8–16 cores, 300+ users)
```apache
<IfModule mpm_prefork_module>
    StartServers            5
    MinSpareServers         5
    MaxSpareServers         10
    MaxRequestWorkers       250
    MaxConnectionsPerChild  10000
</IfModule>
```
## 2. Koha Plack Config (koha-conf.xml)
Path: `/etc/koha/sites/[instancename]/koha-conf.xml`

```xml
<koha>
    <!-- Small Server -->
    <plack_max_workers>3</plack_max_workers>
    <plack_max_requests>500</plack_max_requests>

    <!-- Medium Server -->
    <!-- <plack_max_workers>5</plack_max_workers>
    <plack_max_requests>1000</plack_max_requests> -->

    <!-- Large Server -->
    <!-- <plack_max_workers>8</plack_max_workers>
    <plack_max_requests>2000</plack_max_requests> -->

    <plack_env>deployment</plack_env>
</koha>
```
##### Note: Uncomment the relevant block for your server size.

## 3. Restart Services
After editing the configuration files, restart Apache and Koha Plack:

```bash
# Restart Apache
sudo systemctl restart apache2

# Restart Koha Plack instance
sudo koha-plack --restart [instancename]

# Or if using systemd service
sudo systemctl restart koha-plack@[instancename].service
```
Verify Status
```bash
# Apache status
sudo systemctl status apache2

# Check Plack workers
ps aux | grep starman
```
## 4. Additional Tips

#### 1. Backup Configs: 
```bash
sudo cp /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf.bak
sudo cp /etc/koha/sites/[instancename]/koha-conf.xml /etc/koha/sites/[instancename]/koha-conf.xml.bak
```
#### 2. Monitoring:

```bash
htop
tail -f /var/log/koha/[instancename]/plack.log
```
#### 3. Caching:
Consider enabling memcached for session and OPAC caching to reduce database load. This can significantly improve response times under heavy traffic.

#### 4. Performance Testing:
Use tools like ab (ApacheBench) or wrk to simulate concurrent users and check response times:

```bash
# Example ApacheBench test: 1000 requests, 50 concurrent
ab -n 1000 -c 50 http://your-koha-server/

# Example wrk test: 30 seconds, 50 threads, 200 connections
wrk -t50 -c200 -d30s http://your-koha-server/
```
#### 5. Optimization:

- Rotate Plack workers using plack_max_requests to prevent memory leaks.

- Consider SSD storage for the database and indexes (Zebra/ElasticSearch).

- Run reindexing tasks during off-peak hours.
