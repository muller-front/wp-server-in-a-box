# Use the official WordPress image with FPM as a base.
FROM wordpress:fpm

# Add a powerful helper script to install PHP extensions.
# It automatically resolves all system dependencies (apt-get).
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Make the script executable.
RUN chmod +x /usr/local/bin/install-php-extensions

# Use the script to install our required modules at once. Simple and clean.
RUN install-php-extensions imagick intl
