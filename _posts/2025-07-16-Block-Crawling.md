---
layout: post
title:  "Block Google (and other search engines) from crawling your Koha OPAC** safely and properly"
date:   2025-07-16 12:00:00 +0530
tags: [Stop-crawling, Robots, Googlebot, Ubuntu, Dspace, Koha, CMS]
---

# Block Google (and other search engines) from crawling your Koha OPAC** safely and properly


## 📌 **Method 1: Use `robots.txt`**

Koha’s OPAC usually runs on Apache or another web server. You can add a `robots.txt` file to the OPAC’s root directory.

### Step 1: **Create the `robots.txt` file**  
Example content to block all crawlers:

```plaintext
User-agent: *
Disallow: /
```
This means: _all user agents (crawlers) are disallowed from crawling anything._

**Block Google only**:

```plaintext
User-agent: Googlebot
Disallow: /
```

###  Step 2:  **Save it** 
in your Koha OPAC root directory — typically `/usr/share/koha/opac/htdocs/` or wherever your Koha OPAC is served from.

### Step 3: Make sure it’s accessible at:
`https://your-opac-domain/robots.txt`

---

## 📌 **Method 2: Add `X-Robots-Tag` Header**

If you want a stronger block, add this HTTP header to OPAC pages:

```apache
Header set X-Robots-Tag "noindex, nofollow"
```

**How to do this in Apache:**

Add this to your OPAC’s virtual host config (`/etc/apache2/sites-available/koha.conf` or equivalent):

```apache
<Directory /usr/share/koha/opac/htdocs>
    Header set X-Robots-Tag "noindex, nofollow"
</Directory>
```
Then reload Apache:

```bash
sudo systemctl reload apache2
```

---

## 📌 **Method 3: Add `<meta>` tag in OPAC templates**

You can also add:

```html
<meta  name="robots"  content="noindex, nofollow">
```

in the OPAC page `<head>` section (`opac-main.tt` or similar template).

But the `robots.txt` + `X-Robots-Tag` header is usually enough.

---

## ✅ **Remember**

-   `robots.txt` is only advisory — good bots (like Google) respect it, bad bots may not.
    
-   The `X-Robots-Tag` header is stronger because it’s in the HTTP response.
    
-   Make sure you **don’t block your Koha staff client** — usually you only block the OPAC.
