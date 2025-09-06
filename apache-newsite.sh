#!/bin/bash

# Welcome message
echo "Welcome to the Apache New Site Setup Script!"
echo "This script will help you set up a new Apache virtual host."
echo "Please ensure you have sudo privileges to run this script."
echo ""
# Prompt for domain name
read -p "Enter the domain name (e.g., example.com): " DOMAIN

# Prompt for document root
read -p "Enter the document root, leave blank for default (/var/www/$DOMAIN): " DOCROOT

# Validate and set default document root if empty
if [ -z "$DOCROOT" ]; then
    DOCROOT="/var/www/$DOMAIN"
fi

# Make sure the document root directory exists
if [ ! -d "$DOCROOT" ]; then
    echo "Document root $DOCROOT does not exist. Creating it now..."
    sudo mkdir -p "$DOCROOT"
    sudo chown -R $USER:$USER "$DOCROOT"
    sudo chmod -R 755 "$DOCROOT"
    echo "Document root created."
fi

# Print Domain and Document Root
echo ""
echo "You have entered the following details:"
echo "Domain Name: $DOMAIN"
echo "Document Root: $DOCROOT"
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
    DocumentRoot $DOCROOT

    <Directory $DOCROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined
</VirtualHost>
EOL"

echo "Apache configuration file created."
echo ""
echo ""

# a2ensite $DOMAIN.conf
sudo a2ensite $DOMAIN.conf > /dev/null 2>&1
echo ""

# Check apache configuration
echo "Checking Apache configuration..."
sudo apache2ctl configtest > /dev/null 2>&1
echo ""

if [ $? -eq 0 ]; then
    echo "Apache configuration syntax is OK."
    echo ""
else
    echo "Apache configuration syntax has errors. Please review the output above."
    exit 1
fi


# Reload apache
echo "Reloading Apache to apply changes..."
sudo systemctl reload apache2
echo ""

# Final message
echo "Setup complete! Your new site $DOMAIN is now configured."
echo "Please ensure that your DNS settings point to this server's IP address."
echo "You can place your website files in the document root: $DOCROOT"


