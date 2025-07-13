#!/bin/bash

# Docusaurus + nginx + Let's Encrypt Setup Script
# This script sets up Docusaurus with nginx and SSL encryption

set -e

# Configuration variables (UPDATE THESE)
DOMAIN="yourdomain.com"
EMAIL="your-email@example.com"
WEBSITE_DIR="/var/www/$DOMAIN"
BUILD_DIR="/path/to/your/docusaurus/build"

echo "🚀 Setting up Docusaurus with nginx and Let's Encrypt SSL"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)" 
   exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install nginx
echo "🌐 Installing nginx..."
apt install nginx -y

# Install certbot for Let's Encrypt
echo "🔒 Installing certbot..."
apt install certbot python3-certbot-nginx -y

# Create website directory
echo "📁 Creating website directory..."
mkdir -p $WEBSITE_DIR
chown -R www-data:www-data $WEBSITE_DIR

# Copy Docusaurus build files
echo "📋 Copying Docusaurus build files..."
if [ -d "$BUILD_DIR" ]; then
    cp -r $BUILD_DIR/* $WEBSITE_DIR/
    chown -R www-data:www-data $WEBSITE_DIR
else
    echo "⚠️  Build directory not found: $BUILD_DIR"
    echo "Please run 'npm run build' in your Docusaurus project first"
fi

# Backup default nginx config
echo "💾 Backing up default nginx config..."
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create nginx configuration
echo "⚙️  Creating nginx configuration..."
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Temporary location for Let's Encrypt verification
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect all other HTTP requests to HTTPS (will be added after SSL setup)
    location / {
        root $WEBSITE_DIR;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Enable the site
echo "🔗 Enabling nginx site..."
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Restart nginx
echo "🔄 Restarting nginx..."
systemctl restart nginx

# Obtain SSL certificate
echo "🔐 Obtaining SSL certificate from Let's Encrypt..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# Update nginx config with SSL and security headers
echo "🛡️  Updating nginx configuration with SSL and security headers..."
cat > /etc/nginx/sites-available/$DOMAIN << 'EOF'
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL Certificate paths (managed by Certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Document root
    root $WEBSITE_DIR;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    # Handle client-side routing
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary "Accept-Encoding";
    }
    
    # Security - deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Logs
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;
}
EOF

# Test and reload nginx
echo "🧪 Testing nginx configuration..."
nginx -t

echo "🔄 Reloading nginx..."
systemctl reload nginx

# Setup automatic certificate renewal
echo "🔄 Setting up automatic certificate renewal..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

# Enable and start nginx service
echo "🔧 Enabling nginx service..."
systemctl enable nginx

# Display final status
echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "🌐 Your Docusaurus site is now available at:"
echo "   https://$DOMAIN"
echo "   https://www.$DOMAIN"
echo ""
echo "🔒 SSL certificate is installed and will auto-renew"
echo "📊 nginx logs are available at:"
echo "   Access: /var/log/nginx/${DOMAIN}_access.log"
echo "   Error:  /var/log/nginx/${DOMAIN}_error.log"
echo ""
echo "📝 To update your site:"
echo "   1. Run 'npm run build' in your Docusaurus project"
echo "   2. Copy the build files to $WEBSITE_DIR"
echo "   3. Set proper ownership: chown -R www-data:www-data $WEBSITE_DIR"
echo ""
