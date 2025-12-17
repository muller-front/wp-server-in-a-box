#!/bin/bash
set -e

echo "--- Starting the 'WP-Server-in-a-Box' provisioning/update script ---"

# Detect the script's directory for portability
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Project directory detected: $SCRIPT_DIR"

# Check if the .env file exists
ENV_FILE="$SCRIPT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "--- Config file (.env) not found! ---"
    echo "Starting interactive setup..."
    
    # Prompt for secrets
    read -sp "Enter a secure password for the Database Root User: " DB_ROOT_PASS && echo ""
    read -sp "Enter a secure password for the WordPress Database User: " DB_WP_PASS && echo ""
    
    # Generate .env file
    echo "--- Generating .env file... ---"
    cat > "$ENV_FILE" <<EOF
# Database Passwords (Auto-generated)
MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS
MYSQL_PASSWORD=$DB_WP_PASS

# Other Configuration
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
NPM_DB_NAME=npm
NPM_DB_USER=npm
EOF
    echo "✅ .env file created successfully."
else
    echo "--- Found existing .env file. using it. ---"
fi

# ==================================================================================
# DOCKER INSTALLATION SECTION (IDEMPOTENT)
# ==================================================================================
if ! command -v docker &> /dev/null
then
    echo "--- Docker not found. Starting installation... ---"
    
    echo "--- Step 0: Installing basic tools (curl) ---"
    sudo apt-get update
    sudo apt-get install -y curl

    echo "--- Step 1: Installing Docker using official script ---"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    echo "--- Adding current user to docker group ---"
    CURRENT_USER=${USER:-$(whoami)}
    if [ -n "$CURRENT_USER" ]; then
        sudo usermod -aG docker "$CURRENT_USER" || true
        echo "NOTE: Group changes take effect on next login."
    else
        echo "WARNING: Could not determine current user. Skipping usermod."
    fi
else
    echo "--- Docker is already installed. ---"
fi

echo "--- Verifying installations ---"
docker --version
docker compose version

# ==================================================================================
# CONTAINER ORCHESTRATION SECTION
# ==================================================================================

# Function to check if Docker is running (with retries and sudo fallback)
wait_for_docker() {
    echo "--- Checking Docker Daemon status... ---"
    local retries=30
    local count=0
    
    # Explicitly try to start it just in case
    sudo systemctl start docker || true

    while [ $count -lt $retries ]; do
        if sudo docker info &> /dev/null; then
            echo "✅ Docker Daemon is running and accessible."
            return 0
        fi
        echo "⏳ Waiting for Docker Daemon to start... ($((count+1))/$retries)"
        sleep 1
        count=$((count+1))
    done
    
    return 1
}

if ! wait_for_docker; then
    echo "❌ ERROR: Docker daemon failed to start or is not accessible."
    echo "Please check 'sudo systemctl status docker' manually."
    exit 1
fi

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

# ==================================================================================
# FINAL OUTPUT
# ==================================================================================
echo ""
echo "--- ✅ SUCCESS! ---"
echo "The WordPress environment has been provisioned/updated."
echo "Please follow these manual steps to finish setup:"
echo ""
echo "1. Set up the Nginx Proxy Manager at http://YOUR_VM_IP:81"
echo "   (Default user: admin@example.com / password: changeme)"
echo "2. Create a DNS A record (e.g., yourdomain.com) pointing to this VM's IP address."
echo "3. In NPM, add a Proxy Host for 'yourdomain.com':"
echo "   - On the 'Details' tab, use 'Forward Hostname / IP' as 'wp_nginx' on port 80."
echo "   - Also, enable the 'Block Common Exploits' option."
echo "   - On the 'SSL' tab, request a new certificate and enable 'Force SSL' and 'HTTP/2 Support'."
echo "4. Access 'https://yourdomain.com' and complete the famous 5-minute WordPress installation."
echo "5. (Optional) To restore a backup, install your migration plugin (like WPVivid) and follow its instructions."

echo ""
