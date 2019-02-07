#!/bin/bash

#
# This file should be used to prepare and run your WebProxy after set up your .env file
# Source: https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
#

# Check if .env file exists
if [ -e .env ]; then
    source .env
else 
    echo "Please set up your .env file before starting your environment."
    exit 1
fi

# Create docker network
docker network create $NETWORK $NETWORK_OPTIONS

# Verify if second network is configured
if [ ! -z ${SERVICE_NETWORK+X} ]; then
    docker network create $SERVICE_NETWORK $SERVICE_NETWORK_OPTIONS
fi

# Download the latest version of nginx.tmpl
curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > nginx.tmpl

# Build images
docker-compose -f docker-compose-nginx-proxy.yml pull

# Add any special configuration if it's set in .env file
# Check if user set to use Special Conf Files
if [ ! -z ${USE_NGINX_CONF_FILES+X} ] && [ "$USE_NGINX_CONF_FILES" = true ]; then

    # Create the conf folder if it doesn't exist
    mkdir -p $NGINX_FILES_PATH/conf.d

    # Copy the special configurations to the nginx conf folder
    cp -R ./conf.d/* $NGINX_FILES_PATH/conf.d

    # Check if there was an error and try with sudo
    if [ $? -ne 0 ]; then
        sudo cp -R ./conf.d/* $NGINX_FILES_PATH/conf.d
    fi

    # If there was any errors inform the user
    if [ $? -ne 0 ]; then
        echo
        echo "#######################################################"
        echo
        echo "There was an error trying to copy the nginx conf files."
        echo "The webproxy will still work, your custom configuration"
        echo "will not be loaded."
        echo 
        echo "#######################################################"
    fi
fi 

# Create the vhost folder if it doesn't exist
mkdir -p $NGINX_FILES_PATH/vhost.d

# Copy the location config to the nginx vhost folder
cp ./site_location.tmpl $NGINX_FILES_PATH/vhost.d/${PARKOUR_HOST}_location

# Check if there was an error and try with sudo
if [ $? -ne 0 ]; then
    sudo cp ./site_location.tmpl $NGINX_FILES_PATH/vhost.d/${PARKOUR_HOST}_location
fi

# Start nginx proxy
docker-compose -f docker-compose-nginx-proxy.yml up -d

# Build Parkour images
docker-compose -f docker-compose-parkour.yml build

# Start Parkour containers
docker-compose -f docker-compose-parkour.yml up -d

# Migrate database tables, collect static files, and create an admin account
docker-compose -f docker-compose-parkour.yml exec parkour-web python manage.py migrate
docker-compose -f docker-compose-parkour.yml exec parkour-web python manage.py collectstatic --no-input --verbosity 0
docker-compose -f docker-compose-parkour.yml exec parkour-web python manage.py createsuperuser

exit 0
