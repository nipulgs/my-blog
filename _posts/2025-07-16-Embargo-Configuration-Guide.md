---
layout: post
title:  "DSpace 6.3 – Embargo Configuration Guide"
date:   2025-07-16 12:00:00 +0530
tags: [Dspace, IDR, Embargo]
---

# DSpace 6.3 – Embargo Configuration Guide


This guide explains how to configure and manage embargo (temporary access restriction) on items in a **DSpace 6.3** repository. Embargo allows bitstreams to remain inaccessible to the public until a specified future date.

---

## Step 1: Enable Embargo in Configuration

Edit the main DSpace configuration file:

```bash
nano [dspace]/config/dspace.cfg
```
Add or confirm the following settings:

```bash
# Enable embargo feature
embargo.enabled = true

# Metadata fields
embargo.field.terms = dc.embargo.terms
embargo.field.lift = dc.date.available

# Default embargo plugins
plugin.named.org.dspace.embargo.EmbargoSetter = org.dspace.embargo.DefaultEmbargoSetter
plugin.named.org.dspace.embargo.EmbargoLifter = org.dspace.embargo.DefaultEmbargoLifter
```

Save and close the file.

## Step 2: Update Submission Form

To allow users to enter embargo dates during submission, edit:

```bash
nano [dspace]/config/input-forms.xml
```

In the `<form name="traditional">` section, add this field:

```xml
<field>
  <dc-schema>dc</dc-schema>
  <dc-element>date</dc-element>
  <dc-qualifier>available</dc-qualifier>
  <label>Embargo Lift Date</label>
  <input-type>date</input-type>
  <hint>Enter the date after which this item will become publicly accessible</hint>
  <required>no</required>
</field>
```
Restart Tomcat to apply changes:

```bash
sudo systemctl restart tomcat7
```
## Step 3: Submit Items with Embargo Dates

During submission:

- Use the Embargo Lift Date field to enter a future date.
- This sets the dc.date.available metadata field.
- Bitstreams will be restricted from anonymous access until that date.

## Step 4: Embargo Setter Behavior

When an embargo date is set:

 - Anonymous users cannot access bitstreams.
 - DSpace sets a future READ policy that activates on the embargo lift date.
 - The embargo lifter script will update access policies when the date is reached.

## Step 5: Schedule the Embargo Lifter Script

You can run the embargo-lifter manually or schedule it.

Run manually:

```bash
[dspace]/bin/dspace embargo-lifter
```

Automate with Cron:
Edit crontab:

```bash
crontab -e
```

Add this line to run daily at 2 AM:

```bash
0 2 * * * /home/dspace/dspace/bin/dspace embargo-lifter >> /home/dspace/embargo.log 2>&1
```

## Step 6: Test Embargo Functionality

 1. Submit an item and set a future embargo date.
 2. Ensure anonymous users cannot access the bitstreams.
 3. After the embargo date passes, run:

	```bash
	[dspace]/bin/dspace embargo-lifter 
	```

4. Confirm that public access is now available.

## Additional Notes

 - Embargo affects bitstream access, not metadata visibility. 
 - To embargo metadata, custom workflows or development is needed. 
 - You can write a custom EmbargoSetter class for advanced logic.


