# WP-Server-in-a-Box

## Project Overview
WP-Server-in-a-Box is an Infrastructure as Code (IaC) solution designed to provision a production-ready WordPress environment on any clean Linux server. Utilizing Docker containerization, it automates the deployment of a secure, high-performance stack, including a reverse proxy with automated SSL management.

## Philosophy
This project follows the "Cattle, not Pets" infrastructure principle. By using automated provisioning scripts, the server environment remains consistent, reproducible, and easy to rebuild. The configuration is stored in code, ensuring that the deployment process is identical across different environments.

## Architecture
The system is composed of several orchestrated Docker containers:

*   **Nginx Proxy Manager:** Acts as the entry point, handling reverse proxying, security auditing, and Let's Encrypt SSL certificate management.
*   **WordPress (PHP-FPM):** A performance-optimized WordPress image pre-configured with essential PHP extensions (e.g., imagick, intl).
*   **MariaDB:** A secure database backend for WordPress data persistence.
*   **Isolated Networks:** All components communicate through dedicated Docker networks to ensure security and isolation.

## Prerequisites
*   A Linux-based server (Ubuntu/Debian recommended).
*   Sudo or Root access.
*   A domain name pointed to the server's public IP address.

## Installation Guide

### 1. Clone the Repository
```bash
git clone https://github.com/muller-front/wp-server-in-a-box.git
cd wp-server-in-a-box
```

### 2. Environment Configuration
The provisioning script includes an interactive setup. If a `.env` file is not present, the script will prompt for the necessary database credentials and generate the configuration automatically. Alternatively, you can configure it manually:
```bash
cp .env.example .env
# Edit .env with your preferred credentials
```

### 3. Provisioning the Server
Run the main deployment script. It will automatically verify dependencies, install Docker if missing, and orchestrate the container stack.
```bash
chmod +x run.sh
./run.sh
```

### 4. Final Configuration
After completion, the script will provide manual steps to finalize the Nginx Proxy Manager setup. This includes:
*   Accessing the management interface on port 81.
*   Configuring the Proxy Host for your domain.
*   Enabling SSL and security features.

## Management Scripts
*   **run.sh**: The primary orchestration script for installation and updates.
*   **destroy.sh**: A management script to decommission the environment. It offers options for basic container removal or a full cleanup, including the deletion of persistent volumes, local data, and Docker images.
*   **set-url.sh**: A troubleshooting utility to update the WordPress site URL directly in the configuration.

## License
This project is licensed under the MIT License.
