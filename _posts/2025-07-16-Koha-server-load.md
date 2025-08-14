---
layout: post
title:  "Common reasons for high Koha server load"
date:   2025-07-16 12:00:00 +0530
tags: [Koha, Koha-server-load, Bots, Plack-workers]
---

# Common reasons for high Koha server load


### 1. **Bots hitting OPAC**

-   Solved by blocking crawlers with `robots.txt` + `X-Robots-Tag`.
    

### 2. **Heavy API usage**

-   Some integrations or scripts might hit `/api/v1/...` endpoints repeatedly.
    
-   You can check logs:
    
```bash   
tail -f /var/log/koha/yourinstance/opac-access.log tail -f /var/log/koha/yourinstance/intranet-access.log
```

### 3. **Plack misconfigured**

-   Not enough or too many Plack workers.
    
-   Misaligned with server RAM/CPU.
    

### 4. **Indexing jobs running too often**

-   Zebra or Elasticsearch indexing can spike usage.
    
---    

### **Solutions** : Here’s what you can do **safely**:
---

### Step 1: **Tune Plack workers**

Koha uses `plack` for faster Perl web serving. Too many or too few workers can cause high load or slow performance.

**Check current workers:**

```bash
cat /etc/koha/sites/yourinstance/koha-conf.xml | grep -i prefork
```

Example section:

```xml
<plack_max_requests>50</plack_max_requests>
<plack_workers>2</plack_workers>
```

**Basic rule:**

-   For **2 CPU cores**, use 2 workers.
    
-   For **4 CPU cores**, try 3–4 workers.
    
---

### Step 2: **Limit bots**

Use:
-   `robots.txt` → stop OPAC crawling.
    
-   `fail2ban` or `iptables` → block aggressive IPs.
    
-   Apache `mod_evasive` → throttle abusive requests.

---

### Step 3: **Optimize Zebra / Elasticsearch**

If you use Zebra:

-   Don’t run indexing too frequently.
    
-   Run at low-traffic times:
    
```bash
sudo koha-rebuild-zebra -v -f yourinstance
``` 
----------

### Step 4: **Check cron jobs**

Sometimes cron jobs hammer the server. Look:

```bash
crontab -l -u koha
``` 

See if `koha-run-backups`, `koha-index-daemon`, or `cronjobs` are too frequent.

----------

### **Key tip**

If you **don’t need Koha’s REST API externally**, block it in Apache or firewall.

Example Apache:

```apache
<Location /api>
   Require ip YOUR.INTERNAL.IP.RANGE
</Location>
```

Or block it completely with:

```apache
RedirectMatch 403 ^/api
```

