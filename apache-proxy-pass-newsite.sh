#!/bin/bash

# Welcome message
echo "Welcome to the Apache New Site Setup Script!"
echo "This script will help you set up a new Apache virtual host."
echo "Please ensure you have sudo privileges to run this script."
echo ""
# Prompt for domain name
read -p "Enter the domain name (e.g., example.com): " DOMAIN

# Prompt for port number
read -p "Enter the port number to proxy to (e.g., 3000): " PORT

# Print Domain and Port
echo ""
echo "You have entered the following details:"
echo "Domain Name: $DOMAIN"
echo "Port Number: $PORT"
echo ""

# Create apache configuration file
APACHE_CONF="/etc/apache2/sites-available/$DOMAIN.conf"
# For test create in the current directory
echo "Creating Apache configuration file at $APACHE_CONF..."
sudo bash -c "cat > $APACHE_CONF <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@$DOMAIN
    ServerName $DOMAIN
    # ServerAlias www.$DOMAIN
    
    ProxyPreserveHost On
    ProxyRequests Off
    ProxyVia Off

    <Proxy *>
        Require all granted
    </Proxy>

    ProxyPass / http://127.0.0.1:$PORT/
    ProxyPassReverse / http://127.0.0.1:$PORT/

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined
</VirtualHost>
EOL"

echo "Apache configuration file created."
echo ""

# Enable the new site
echo "Enabling the new site $DOMAIN..."
sudo a2ensite $DOMAIN.conf > /dev/null 2>&1
echo ""

# Check apache configuration
echo "Checking Apache configuration..."
sudo apache2ctl configtest > /dev/null 2>&1
echo ""

# Reload apache to apply changes
echo "Reloading Apache to apply changes..."
sudo systemctl reload apache2
echo ""

echo "Setup complete! Your new site $DOMAIN is now configured to proxy to port $PORT."
echo "Please ensure that your DNS settings point to this server's IP address."
echo "You can now start your application on port $PORT."
echo ""


