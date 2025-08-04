---
layout: post
title:  "Customizing Handle Display in DSpace 6.3 JSPUI"
date:   2025-08-04
tags: [DSpace,  Customizing Handle, Display]
---

# Customizing Handle Display in DSpace 6.3 JSPUI

Customizing DSpace 6.3 JSPUI: Display Canonical Handle with Configurable Domain This guide explains how to change the citation handle URL in `display-item.jsp` so that it uses a fixed base URL (like `https://dspace.iiti.ac.in/handle/`) and makes that domain configurable via `dspace.cfg`.

## 📁 Step 1: Add Property to `dspace.cfg` Open the DSpace configuration file located at:`` 

`[dspace]/config/dspace.cfg`

Add this  new property at the end of the file:

```properties
	jspui.citation.baseurl = https://dspace.iiti.ac.in` 
```
----------

## 🖊️ Step 2: Edit `display-item.jsp`

Open:

`[dspace-src]/dspace-jspui/src/main/webapp/item/display-item.jsp` 

Find and replace the existing citation display block with the following code:

```jsp
<% String  baseUrl  = org.dspace.core.ConfigurationManager.getProperty("jspui.citation.baseurl");
%>
<div class="well">
    <fmt:message key="jsp.display-item.identifier"/>
    <code><%= baseUrl + "/handle/" + item.getHandle() %></code>
</div>
```

>💡 Note: `ConfigurationManager` is part of the DSpace API and allows access to properties defined in `dspace.cfg`. 

----------

## ⚙️ Step 3: Rebuild and Deploy JSPUI

### 🔧 Rebuild JSPUI:

```
	cd [dspace-src]/dspace
	mvn package
```

### 📦 Redeploy JSPUI:
```
	cp -r [dspace]/webapps/jspui [tomcat]/webapps/
```

### 🔁 Restart Tomcat:

```bash
	sudo systemctl restart tomcat
```

## ✅ Result

"Please use this identifier to cite or link to this item:" section will now show:

`https://dspace.iiti.ac.in/handle/123456789/14373` 

And the base domain (`https://dspace.iiti.ac.in`) is now configurable in `dspace.cfg`.

----------
