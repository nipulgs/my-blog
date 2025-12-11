---
layout: post
title:  "Secure DSpace 6.3 with Let's Encrypt SSL"
date:   2023-08-10 12:00:00 +0530
tags: [SSL, Dspace, Secure DSpace]
---


# Secure DSpace 6.3 with Let's Encrypt SSL
> Domain: `dspace.iiti.ac.in`  
> Environment: Apache HTTP Server (Reverse Proxy) + Tomcat 9 + Ubuntu/Debian

---

## Step 1: Install Certbot

```bash
sudo apt update
sudo apt install certbot python3-certbot-apache
```

---

## Step 2: Configure Apache as Reverse Proxy

Create a new Apache site config:

```bash
sudo nano /etc/apache2/sites-available/dspace.iiti.ac.in.conf
```

Paste:

```apache
<VirtualHost *:80>
    ServerName dspace.iiti.ac.in

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    ErrorLog ${APACHE_LOG_DIR}/dspace_error.log
    CustomLog ${APACHE_LOG_DIR}/dspace_access.log combined
</VirtualHost>
```

Enable necessary modules and site:

```bash
sudo a2enmod proxy proxy_http headers
sudo a2ensite dspace.iiti.ac.in
sudo systemctl restart apache2
```

Test by visiting:  
http://dspace.iiti.ac.in

---

## Step 3: Obtain SSL Certificate

Run the following to issue and configure the SSL cert:

```bash
sudo certbot --apache -d dspace.iiti.ac.in
```

Follow the interactive prompts and choose to redirect HTTP to HTTPS if prompted.

---

## Step 4: Review Apache HTTPS Configuration (Auto-added by Certbot)

```apache
<VirtualHost *:443>
    ServerName dspace.iiti.ac.in

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/dspace.iiti.ac.in/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/dspace.iiti.ac.in/privkey.pem

    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
```

---

## Step 5: Enable Auto-Renewal with Cron (Optional)

Certbot auto-renewal runs via systemd. To verify:

```bash
systemctl list-timers | grep certbot
```

Optional: Add a cron job manually:

```bash
sudo crontab -e
```

Add:

```cron
30 2 * * * certbot renew --quiet --post-hook "systemctl reload apache2"
```

---

## Step 6: Test Renewal

```bash
sudo certbot renew --dry-run
```

---

## Step 7: Optional - Force HTTPS Redirect

Edit Apache HTTP config if not already redirected:

```apache
<VirtualHost *:80>
    ServerName dspace.iiti.ac.in
    Redirect permanent / https://dspace.iiti.ac.in/
</VirtualHost>
```

Reload Apache:

```bash
sudo systemctl reload apache2
```

---

## Result

- HTTPS active: https://dspace.iiti.ac.in  
- Apache Reverse Proxy to Tomcat 9  
- Let's Encrypt SSL with auto-renewal

---
