# WP-Server-in-a-Box 🚀 (v1.0)

An Infrastructure as Code (IaC) project that provisions a complete, secure, and containerized WordPress server with a single command. Ideal for developers, agencies, or anyone who needs a robust and portable WordPress environment.

## Philosophy

This project follows the **"Cattle, not Pets"** philosophy. The server is designed to be disposable and 100% reproducible from code. The intelligence is not in the machine itself, but in the version-controlled scripts and configuration files.

## Architecture

The solution is based on Docker and Docker Compose, utilizing a microservices architecture with network isolation:

- **Nginx Proxy Manager:** Acts as the main gateway, managing all incoming traffic, routing, and the automation of SSL certificates (Let's Encrypt).

- **WordPress Stack:**
  - **Webserver (Nginx):** Serves static files and proxies requests to the application.
  - **Application (WordPress):** A custom image based on `wordpress:fpm`, built via a `Dockerfile` to include essential PHP extensions (`imagick`, `intl`).
  - **Database (MariaDB):** A `mariadb:10` container with data persistence guaranteed by a named volume.

- **Docker Networks:**
  - `proxy_network`: An external shared network for communication between the Proxy Manager and the application's Nginx container.
  - `app-network`: An internal, isolated network for communication between Nginx, WordPress, and the Database.

## Prerequisites

- A server running Ubuntu 22.04 LTS (or newer).
- `root` access or a user with `sudo` privileges.
- A domain name pointed to your server's IP address.

## 🚀 Quick Start Guide (Provisioning)

1.  **Clone this repository onto your server:**
    ```bash
    git clone https://github.com/muller-front/wp-server-in-a-box.git
    cd wp-server-in-a-box
    ```

2.  **Create and configure your secrets file:**
    ```bash
    cp .env.example .env
    nano .env # Edit the file with your own secure passwords
    ```

3.  **Run the provisioning script:**
    ```bash
    chmod +x run.sh
    ./run.sh # Use 'sudo ./run.sh' if your user is not in the docker group
    ```

After the script finishes, follow the on-screen instructions to set up the Nginx Proxy Manager and complete the WordPress installation through your browser.

## ⚙️ Automation Scripts

- **`run.sh`:** The main bootstrap script. It installs Docker (if not present) and brings up all the stacks. This script also update containers images if WP-Server-in-a-Box is running.

- **`destroy.sh`:** Stops, removes, and cleans up all containers and networks created by this project.

- **`set-url.sh`:** An emergency utility script to force the site's URL (HTTP/IP) in the `wp-config.php` file, useful for diagnostics.

## License

This project is distributed under the MIT License. See the `LICENSE` file for more details.
