#!/bin/bash
set -e

# ==================================================================================
# URL CONFIGURATION SCRIPT (HTTP)
#
# What it does:
# 1. Asks the user for the IP or domain they want to use.
# 2. Removes any old WP_HOME/WP_SITEURL definitions from wp-config.php.
# 3. Inserts the new definitions (with http://) in the correct place.
# 4. Fixes the file permissions, in case they were changed.
# ==================================================================================

echo "--- URL Configuration Script (HTTP) for wp-config.php ---"

# Detect the script's directory for portability
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CONFIG_FILE="$SCRIPT_DIR/wordpress-stack/wordpress/wp-config.php"
CONFIG_DIR="$SCRIPT_DIR/wordpress-stack/wordpress"

# 1. Check if wp-config.php exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "\033[1;31mERROR: '$CONFIG_FILE' not found.\033[0m"
    echo "Please access the site and complete the WordPress installation first."
    exit 1
fi

# 2. Ask the user for the IP or Domain
read -p "Enter the IP or domain to use (e.g., 52.14.227.36 or yourtest.com): " DOMAIN_OR_IP

# 3. Validate the input
if [ -z "$DOMAIN_OR_IP" ]; then
    echo -e "\033[1;31mNo input detected. Exiting.\033[0m"
    exit 1
fi

# 4. Format the URL
# The 'sed' command removes http:// or https:// in case the user typed it by mistake
CLEAN_DOMAIN=$(echo "$DOMAIN_OR_IP" | sed -e 's,https://,,g' -e 's,http://,,g')
FULL_URL="http://$CLEAN_DOMAIN"

echo "Configuring the site to run at: $FULL_URL"

# 5. Save the original owner and group of the file
# This is crucial, as 'sudo sed' might change the owner to 'root'
ORIGINAL_OWNER=$(stat -c '%U' "$CONFIG_FILE")
ORIGINAL_GROUP=$(stat -c '%G' "$CONFIG_FILE")

# 6. Remove old definitions (to make the script 'idempotent')
echo "Cleaning up old URL definitions (if they exist)..."
# We use 'sudo sed' as the file might belong to www-data
sudo sed -i "/define( *'WP_HOME'/d" "$CONFIG_FILE"
sudo sed -i "/define( *'WP_SITEURL'/d" "$CONFIG_FILE"

# 7. Add the new definitions before the "/* That's all..." line
echo "Inserting new definitions into wp-config.php..."
sudo sed -i "/\/\* That's all, stop editing!/i \
define( 'WP_HOME', '$FULL_URL' );\n\
define( 'WP_SITEURL', '$FULL_URL' );\n" "$CONFIG_FILE"

# 8. Restore the correct permissions and owner
echo "Restoring original permissions ($ORIGINAL_OWNER:$ORIGINAL_GROUP)..."
sudo chown $ORIGINAL_OWNER:$ORIGINAL_GROUP "$CONFIG_FILE"
sudo chmod 644 "$CONFIG_FILE"

echo ""
echo "--- ✅ SUCCESS! ---"
echo "The wp-config.php file has been updated."
echo "Your site should now respond at: $FULL_URL"
echo "(Remember to clear your browser cache or use an incognito window)"
