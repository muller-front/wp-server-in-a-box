#!/bin/bash
set -e

echo -e "\033[1;31m\nATTENTION: This script will stop and remove ALL containers and networks for 'WP-Server-in-a-Box'.\033[0m"
read -p "Do you wish to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# The new, more explicit, and dangerous question
echo -e "\033[1;33m"
read -p "Perform a FULL cleanup? This will also PERMANENTLY DELETE all Docker volumes (database) AND local files (WordPress source, NPM data, SSL certificates). This action is IRREVERSIBLE. (y/N) " -n 1 -r
echo -e "\033[0m"
FULL_CLEANUP=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    FULL_CLEANUP=true
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
DOWN_FLAGS=""
if [ "$FULL_CLEANUP" = true ]; then
    DOWN_FLAGS="-v" # Add the flag to remove volumes
fi

echo -e "\n--- Shutting down the WordPress stack ---"
cd "$SCRIPT_DIR/wordpress-stack/"
sudo docker compose down $DOWN_FLAGS

echo -e "\n--- Shutting down the Proxy stack ---"
cd "$SCRIPT_DIR/proxy/"
sudo docker compose down $DOWN_FLAGS

# The new file cleanup section
if [ "$FULL_CLEANUP" = true ]; then
    echo -e "\n--- Deleting local bind-mounted data (WordPress source, NPM data)... ---"
    
    WP_DIR="$SCRIPT_DIR/wordpress-stack/wordpress"
    if [ -d "$WP_DIR" ]; then
        echo "Deleting $WP_DIR..."
        sudo rm -rf "$WP_DIR"
    fi

    NPM_DATA_DIR="$SCRIPT_DIR/proxy/data"
    if [ -d "$NPM_DATA_DIR" ]; then
        echo "Deleting $NPM_DATA_DIR..."
        sudo rm -rf "$NPM_DATA_DIR"
    fi
    
    NPM_LE_DIR="$SCRIPT_DIR/proxy/letsencrypt"
    if [ -d "$NPM_LE_DIR" ]; then
        echo "Deleting $NPM_LE_DIR..."
        sudo rm -rf "$NPM_LE_DIR"
    fi
    
    echo "--- Deleting the custom-built Docker image ---"
    # The '|| true' prevents an error if the image doesn't exist
    sudo docker image rm wp-server-custom-image || true
    
    echo "--- Deleting base images (optional cleanup) ---"
    # Try to remove the base images used by the project. 
    # This might fail if other containers use them, which is fine (hence || true).
    sudo docker image rm jc21/nginx-proxy-manager:latest || true
    sudo docker image rm mariadb:10.6 || true
    sudo docker image rm wordpress:php8.2-fpm || true
fi

echo -e "\n--- Pruning unused Docker networks ---"
sudo docker network prune -f

if [ "$FULL_CLEANUP" = true ]; then
    echo -e "\n--- Pruning unused Docker images ---"
    sudo docker image prune -f
fi

echo -e "\n--- ✅ SUCCESS! The environment has been decommissioned. ---"
