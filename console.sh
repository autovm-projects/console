#!/bin/bash

apt-get update -y

apt-get install -y git nginx curl
apt-get install -y python3 python3-pip python3-certbot-nginx

pip3 install -r requirements.txt

# AutoVM address
while true; do

    echo "Enter the AutoVM address"
    echo "The console server must have access to the AutoVM server"
    echo "Example: http://backend.domain.com"

    read -p "AutoVM address:" autovm

    if [ ! -z "$autovm" ]; then
        break
    fi

done

# AutoVM token
while true; do

    echo "Enter the AutoVM token"
    echo "We do not save the provided token"

    read -p "AutoVM token:" token

    if [ ! -z "$token" ]; then
        break
    fi

done

# Console address
while true; do

    echo "Enter the console address"
    echo "You have to create a wildcard subdomain in your domain service provider"
    echo "Example: console.domain.com"

    read -p "Console address:" console

    if [ ! -z "$console" ]; then
        break
    fi

done

# Create domain 
function createDomain {

    domain=$(echo "$1" | md5sum | grep -Eo [a-z0-9]+ | cut -c1-20)

    echo "$domain.$console"
}

# Create config
function createConfig {

    config=$(cat proxy.conf)

    config=$(echo "$config" | sed "s#@domain#$1#g" | sed "s#@host#$2#g")

    site="/etc/nginx/sites-enabled/$1"

    echo "$config" > "$site"

    echo "$site"
}

# Check domain
function checkDomain {

    output=$(ping -c 2 "$1" &> /dev/null && echo success)

    echo "$output"
}

# Create certificate
function createCertificate {

    output=$(certbot --nginx -d $1 --non-interactive --agree-tos --register-unsafely-without-email --quiet --redirect)

    echo "$output"
}

# Create proxy
function createProxy {

    echo "Going to create proxy for host $1"

    domain=$(createDomain "$1")

    echo "Domain for the host is $domain"

    success=$(checkDomain "$domain")

    if [ -z "$success" ]; then

        echo "Domain is not accessible"
    else

        config=$(createConfig "$domain" "$1")

        if [ ! -f "$config" ]; then

            echo "Could not create config"
        else

            certificate=$(createCertificate "$domain")

            proxy=$(python3 create.py "$autovm" "$token" "$1" "$domain")

            if [ $? -lt 1 ]; then

                echo "Successfully created"
            fi
        fi
    fi
}

# List of hosts
hosts=$(python3 hosts.py "$autovm" "$token")

if [ $? -lt 1 ]; then

    while read host; do

        createProxy "$host"

    done <<< "$hosts"

fi