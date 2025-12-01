#!/bin/bash
set -e

echo "--- Starting the 'WP-Server-in-a-Box' provisioning/update script ---"

# Detect the script's directory for portability
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Project directory detected: $SCRIPT_DIR"

# Check if the .env file exists
ENV_FILE="$SCRIPT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "\033[1;31mERROR: .env file not found!\033[0m"
    echo "Please copy .env.example to .env and fill in your passwords."
    exit 1
fi

# ==================================================================================
# DOCKER INSTALLATION SECTION (IDEMPOTENT)
# ==================================================================================
if ! command -v docker &> /dev/null
then
    echo "--- Docker not found. Starting installation... ---"
    echo "--- Step 1: Removing old Docker versions (if any) ---"
    sudo apt-get remove docker docker-engine docker.io containerd runc -y || true

    echo "--- Step 2: Updating system and installing dependencies ---"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y ca-certificates curl gnupg unzip

    echo "--- Step 3: Adding Docker's official GPG key and repository ---"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    echo "--- Step 4: Installing Docker Engine and Compose V2 ---"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "--- Docker is already installed. Skipping installation. ---"
fi

echo "--- Verifying installations ---"
docker --version
docker compose version

# ==================================================================================
# CONTAINER ORCHESTRATION SECTION
# ==================================================================================

# List of stacks to be managed
STACKS=("proxy" "wordpress-stack")

for stack in "${STACKS[@]}"; do
    echo -e "\n--- Processing stack: $stack ---"
    STACK_PATH="$SCRIPT_DIR/$stack"

    if [ -d "$STACK_PATH" ]; then
        cd "$STACK_PATH"

        # Update/create logic
        if [ "$stack" == "wordpress-stack" ]; then
            echo "=> Checking/Updating the WordPress stack (with build)..."
            sudo docker compose --env-file "$ENV_FILE" up -d --build
        else
            echo "=> Checking/Updating the Proxy stack..."
            sudo docker compose pull
            sudo docker compose up -d
        fi
    else
        echo "WARNING: Directory '$STACK_PATH' not found. Skipping."
    fi
done

echo -e "\n--- Pruning old Docker images ---"
sudo docker image prune -f

echo ""
echo "--- ✅ SUCCESS! ---"
echo "The WordPress environment has been provisioned/updated."
echo "If this is the first run, follow the manual steps below:"
echo "1. Set up the Nginx Proxy Manager at YOUR_VM_IP:81"
echo "   (Default user: admin@example.com / password: changeme)"
echo "2. Create a DNS A record (e.g., yourdomain.com) pointing to this VM's IP address."
echo "3. In NPM, add a Proxy Host for 'yourdomain.com':"
echo "   - On the 'Details' tab, use 'Forward Hostname / IP' as 'wp_nginx' on port 80."
echo "   - Also, enable the 'Block Common Exploits' option."
echo "   - On the 'SSL' tab, request a new certificate and enable 'Force SSL' and 'HTTP/2 Support'."
echo "4. Access 'https://yourdomain.com' and complete the famous 5-minute WordPress installation."
echo "5. (Optional) To restore a backup, install your migration plugin (like WPVivid) and follow its instructions."
