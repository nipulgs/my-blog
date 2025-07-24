---
layout: post
title:  "Koha 24.11.x — Starman CPU Debug & Fix Checklist"
date:   2025-06-16
tags: [Koha, Koha-server-load, CPU-Debug]
---


## Purpose

Quick reference to debug and fix high CPU or runaway Starman processes on Koha 24.11.x.

---

## Step 1: Check Starman Status

```bash
sudo systemctl status koha-common
ps aux | grep starman
```

Verify master/workers and CPU usage.

## Step 2: Inspect Logs

```bash
tail -f /var/log/koha/<instance>/plack-error.log
tail -f /var/log/koha/<instance>/opac-error.log
tail -f /var/log/koha/<instance>/intranet-error.log
```

Look for errors or stuck requests.

## Step 3: Restart Starman Safely

```bash
sudo koha-plack --restart <instance>
sudo koha-plack --status <instance>
```

Ensure clean restart.

## Step 4: Adjust Worker Count

```bash
sudo koha-plack --stop <instance>
sudo nano /etc/koha/sites/<instance>/plack.psgi
```

Tune `--workers` if needed.

## Step 5: Kill Zombie Processes

```bash
ps aux | grep starman
sudo kill -9 <pid>
```

Terminate orphaned workers.

## Step 6: Update Koha & Perl Dependencies

```bash
sudo apt update
sudo apt upgrade
sudo koha-plack --restart <instance>
```

Apply latest fixes.

## Step 7: Check Long-Running Requests

```bash
sudo netstat -tnp | grep :5000
```

Look for hanging connections.

## Step 8: Set Worker Timeout

Add `--timeout` in config. Example: `--timeout 60`

## Step 9: Monitor After Fix

```bash
htop
sudo koha-plack --status <instance>
```

Monitor CPU, RAM, I/O, plan regular restarts.

---

Keep this checklist saved as `koha_starman_debug.md` or in your server notes.
