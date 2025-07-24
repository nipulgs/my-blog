---
layout: post
title:  "Auto Reboot Ubuntu Server Using Cron"
date:   2023-02-05 12:00:00 +0530
tags: [Reboot, Ubuntu]
---

**Generated:** 2025-07-15 06:22:41  
**System:** Ubuntu (root crontab)

---

## Example Cron Jobs

### Daily Reboot at 3:30 AM

```cron
30 3 * * * /sbin/shutdown -r now
```

### Weekly Reboot Every Sunday at 4:00 AM

```cron
0 4 * * 0 /sbin/shutdown -r now
```

### Alternative with `reboot`

```cron
0 4 * * 0 /sbin/reboot
```

---

## How To Add It

1. Open the **root crontab**:

   ```bash
   sudo crontab -e
   ```

2. Add the desired line.

3. Save and exit.

4. Confirm with:

   ```bash
   sudo crontab -l
   ```

---

## Check Where `reboot` or `shutdown` Lives

```bash
which reboot
which shutdown
```

Usually: `/sbin/reboot` and `/sbin/shutdown`

---

## Check When It Rebooted

```bash
last reboot
```

---

## Tips

- Use root’s crontab, otherwise you won’t have permission.
- Only schedule reboots if needed (e.g., kernel updates).
- Consider using `unattended-upgrades` for auto patching.

---

## Example for Safe Use

```bash
0 4 * * 0 /sbin/shutdown -r now
```

This will reboot your Ubuntu server every Sunday at 4:00 AM.

---
