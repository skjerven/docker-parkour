# Parkour Docker

A 'Dockerized' implementation of [Parkour LIMS](https://github.com/maxplanck-ie/parkour), that uses Nginx and Letsencrypt certificates

## Overview

This repository contains a Docker impelementation of Parkour, along with a containerised Nginx reverse proxy that uses Letsencrypt SSL certificates (and automatically updates them).

![Web Proxy environment](https://github.com/evertramos/images/raw/master/webproxy.jpg)

The Parkour Docker container is taken from Max Planck's [existing container](https://github.com/maxplanck-ie/docker-parkour) (I've made no changes to the Parkour Dockerfile).

The Nginx portion is based off of 2 repos that provide an Nginx proxy/Letsencrypt utility:

* [nginx-letsencrypt-companion](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion)
* [nginx-proxy](https://github.com/jwilder/nginx-proxy)

More documenation on the different options available for these containers can found in the links above.


## Installation

### Step 1

Install [docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/#install-compose).

If you're doing this on a Pawsey Nimbus VM, docker and docker-compose are already installed

### Step 2

Clone this repository:

```
git clone https://github.com/skjerven/docker-parkour.git
cd docker-parkour
```

### Step 3

Set options in the `.env` file.  

In this file are a number of options that control how your Parkour container is set up, as well as options for the Nginx proxy and network.

The important ones to change are:

* PARKOUR_HOST
* EMAIL
* POSTGRES_PASSWORD

The `PARKOUR_HOST` variable is the hostname of the server you're using to run and host Parkour.  You'll need to decide on a hostname and handle setting up any kind of DNS records.

The `EMAIL` is the email address that will be associated with the generated Letsencrypt certificates.

The `POSTGRES_PASSWORD` is the password that will protect your generated Postgres database used by Parkour.

### Step 4

There is a set-up script that will build and pull images, start up the containers, and do the intiail Parkour set-up (database creation, static file migration, admin user creation).

Simply run:

```
./start-parkour.sh
```
and follow the prompts (you'll be asked to set up and admin user for Parkour).

### Other Info

There are 2 docker-compose scripts that handle setting things up; one handles the Nginx reverse proxy and SSL certificates, and the other handles Parkour (web front-end and database).  The `start-parkour.sh` script is mainly for a fresh install.  If you need to make some changes, you can bring down either the Nginx or the Parkour componet with the respective docker-compose example.

For example, if you need to make some changes to the Parkour set-up, you can simply do the following to restart Parkour:

```
source .env
docker-compose -f docker-compose-parkour.yml up -d
```

The `.env` contains the relevant variables, so you'll need to source this for the docker-compose script to have the correct information.

The `docker-compose` line simply uses the Parkour-specific file, and restarts the containers in the background (daemon mode).

