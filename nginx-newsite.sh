#!/bin/bash

# Welcome message
echo "Welcome to the Nginx New Site Setup Script!"
echo "This script will help you set up a new Nginx virtual host."
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

# Create nginx configuration file
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

# For test create in the current directory
echo "Creating Nginx configuration file at $NGINX_CONF..."

sudo bash -c "cat > $NGINX_CONF <<EOL
server {
    listen 80;
    server_name $DOMAIN;
    root $DOCROOT;

    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-Content-Type-Options \"nosniff\";
    add_header X-XSS-Protection \"1; mode=block\";

    index index.php index.html index.htm;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    error_page 404 /index.php;

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/$DOMAIN-access.log;
    error_log /var/log/nginx/$DOMAIN-error.log;
}
EOL"

# Enable the new site
sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/

echo "Nginx configuration file created and site enabled."
echo ""

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t > /dev/null 2>&1
echo ""

if [ $? -eq 0 ]; then
    echo "Nginx configuration syntax is OK."
    echo ""
else
    echo "Nginx configuration syntax has errors. Please review the output above."
    exit 1
fi

# Reload Nginx
echo "Reloading Nginx to apply changes..."
sudo systemctl reload nginx
echo ""

# Final message
echo "Setup complete! Your new site $DOMAIN is now configured."
echo "Please ensure that your DNS settings point to this server's IP address."
echo "You can place your website files in the document root: $DOCROOT"
echo ""