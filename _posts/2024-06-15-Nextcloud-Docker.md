---
layout: post
title:  "Nextcloud with Docker Installation Guide"
date:   2024-06-15 12:00:00 +0530
tags: [Nextcloud, Storage, Ubuntu]
---

# Nextcloud with Docker Installation Guide

## Prerequisites

* A Linux server (Ubuntu or Debian recommended) or macOS/Windows with Docker Desktop.
* Docker installed ([https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)).
* Docker Compose installed ([https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)).
* Open ports: 80 (HTTP) and/or 443 (HTTPS).

## Step 1: Create a project directory

```
mkdir nextcloud-docker
cd nextcloud-docker
```

## Step 2: Create docker-compose.yml

Example using Nextcloud and MariaDB:

```
version: '3'

services:
  db:
    image: mariadb
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=secret
      - MYSQL_PASSWORD=secret
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    image: nextcloud
    restart: always
    ports:
      - 8080:80
    links:
      - db
    volumes:
      - nextcloud:/var/www/html
    environment:
      - MYSQL_PASSWORD=secret
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=db

volumes:
  db:
  nextcloud:
```

## Step 3: Start Nextcloud

```
docker-compose up -d
```

## Step 4: Open Nextcloud in your browser

Visit http\://YOUR\_SERVER\_IP:8080 and follow the setup wizard.

## Step 5: (Optional) Enable HTTPS

Use a reverse proxy like Nginx Proxy Manager, Traefik, or Caddy.

## Useful Commands

* Stop:

  ```
  docker-compose down
  ```
* View logs:

  ```
  docker-compose logs -f
  ```
* Update:

  ```
  docker-compose pull
  docker-compose up -d
  ```

## Backups

Ensure volumes (db and nextcloud) are backed up regularly.

## Docs

* Nextcloud Docker Hub: [https://hub.docker.com/\_/nextcloud](https://hub.docker.com/_/nextcloud)
* Nextcloud Admin Manual: [https://docs.nextcloud.com/](https://docs.nextcloud.com/)

Enjoy your private cloud
