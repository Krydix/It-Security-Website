---
sidebar_position: 3
title: Production Deployment - Nginx & Let's Encrypt
description: Complete guide for deploying the IT Security website with Nginx and SSL certificates using Let's Encrypt on Linux
---

# Production Deployment - Nginx & Let's Encrypt

This guide covers deploying the IT Security Study Guide website on a Linux production server using Nginx as a reverse proxy and Let's Encrypt for SSL certificates.

## Prerequisites

- Linux server (Ubuntu 20.04+ or CentOS 8+ recommended)
- Domain name pointing to your server's IP address
- Root or sudo access to the server
- Node.js 18+ installed

## 1. Server Preparation

### Update System Packages

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL/Rocky Linux
sudo dnf update -y
```

### Install Required Dependencies

```bash
# Ubuntu/Debian
sudo apt install -y nginx certbot python3-certbot-nginx git curl

# CentOS/RHEL/Rocky Linux
sudo dnf install -y nginx certbot python3-certbot-nginx git curl
sudo dnf install -y epel-release  # For additional packages
```

### Install Node.js and npm

```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Or for CentOS/RHEL/Rocky Linux
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs npm
```

## 2. Deploy the Website

### Clone the Repository

```bash
# Create a directory for the application
sudo mkdir -p /var/www/it-security
sudo chown -R $USER:$USER /var/www/it-security

# Clone the repository
cd /var/www/it-security
git clone https://github.com/Krydix/It-Security-Website.git .
```

### Install Dependencies and Build

```bash
# Install npm dependencies
npm install

# Build the static site
npm run build
```

### Set Proper Permissions

```bash
# Set ownership to www-data (Ubuntu) or nginx (CentOS)
# Ubuntu/Debian
sudo chown -R www-data:www-data /var/www/it-security

# CentOS/RHEL/Rocky Linux
sudo chown -R nginx:nginx /var/www/it-security

# Set proper permissions
sudo chmod -R 755 /var/www/it-security
```

## 3. Configure Nginx

### Create Nginx Configuration

Create the Nginx server block configuration:

```bash
sudo nano /etc/nginx/sites-available/it-security
```

Add the following configuration (replace `your-domain.com` with your actual domain):

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # Document root
    root /var/www/it-security/build;
    index index.html;
    
    # SSL Configuration (will be added by Certbot)
    # ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: https:; img-src 'self' data: https:;" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    # Handle static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
    
    # Handle routes (for SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Security: Hide nginx version
    server_tokens off;
    
    # Prevent access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # Logging
    access_log /var/log/nginx/it-security.access.log;
    error_log /var/log/nginx/it-security.error.log;
}
```

### Enable the Site

```bash
# Ubuntu/Debian
sudo ln -s /etc/nginx/sites-available/it-security /etc/nginx/sites-enabled/

# CentOS/RHEL/Rocky Linux (place config directly in conf.d)
sudo cp /etc/nginx/sites-available/it-security /etc/nginx/conf.d/it-security.conf
```

### Test Nginx Configuration

```bash
sudo nginx -t
```

If the test is successful, restart Nginx:

```bash
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## 4. Configure Let's Encrypt SSL

### Obtain SSL Certificate

```bash
# Replace your-domain.com with your actual domain
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

Follow the prompts:
1. Enter your email address
2. Agree to the terms of service
3. Choose whether to share your email with EFF
4. Certbot will automatically configure SSL

### Verify SSL Configuration

```bash
# Check certificate status
sudo certbot certificates

# Test automatic renewal
sudo certbot renew --dry-run
```

### Set Up Automatic Renewal

Create a cron job for automatic certificate renewal:

```bash
sudo crontab -e
```

Add the following line to renew certificates twice daily:

```bash
0 12 * * * /usr/bin/certbot renew --quiet
```

## 5. Firewall Configuration

### Configure UFW (Ubuntu/Debian)

```bash
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

### Configure Firewalld (CentOS/RHEL/Rocky Linux)

```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

## 6. Performance Optimization

### Enable HTTP/2

HTTP/2 is already enabled in the Nginx configuration above with the `http2` directive.

### Configure Browser Caching

The Nginx configuration includes optimal caching headers for static assets.

### Monitor Performance

Install and configure monitoring tools:

```bash
# Install htop for system monitoring
sudo apt install htop  # Ubuntu/Debian
sudo dnf install htop  # CentOS/RHEL/Rocky Linux

# Monitor Nginx logs
sudo tail -f /var/log/nginx/it-security.access.log
sudo tail -f /var/log/nginx/it-security.error.log
```

## 7. Automated Deployment Script

Create a deployment script for easy updates:

```bash
sudo nano /var/www/it-security/deploy.sh
```

```bash
#!/bin/bash

# IT Security Website Deployment Script
set -e

echo "🚀 Starting deployment..."

# Navigate to project directory
cd /var/www/it-security

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --production

# Build the project
echo "🔨 Building project..."
npm run build

# Set permissions
echo "🔐 Setting permissions..."
sudo chown -R nginx:nginx /var/www/it-security
sudo chmod -R 755 /var/www/it-security

# Test nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Reload nginx
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

echo "✅ Deployment completed successfully!"
echo "🌐 Website is available at: https://your-domain.com"
```

Make the script executable:

```bash
chmod +x /var/www/it-security/deploy.sh
```

## 8. Security Hardening

### Nginx Security Configuration

Add additional security configurations to your Nginx server block:

```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=main:10m rate=10r/s;

server {
    # Apply rate limiting
    limit_req zone=main burst=20 nodelay;
    
    # Hide server information
    more_clear_headers Server;
    
    # HTTPS Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # ... rest of your configuration
}
```

### System Security

```bash
# Keep system updated
sudo apt update && sudo apt upgrade -y  # Ubuntu/Debian
sudo dnf update -y  # CentOS/RHEL/Rocky Linux

# Configure automatic security updates
sudo apt install unattended-upgrades  # Ubuntu/Debian
sudo dpkg-reconfigure unattended-upgrades
```

## 9. Monitoring and Maintenance

### Log Rotation

Nginx logs are automatically rotated by logrotate. Check the configuration:

```bash
cat /etc/logrotate.d/nginx
```

### Health Checks

Create a simple health check script:

```bash
#!/bin/bash
# Simple health check
curl -f https://your-domain.com > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Website is healthy"
else
    echo "❌ Website is down"
    # Add notification logic here
fi
```

### Backup Strategy

```bash
# Backup script
#!/bin/bash
BACKUP_DIR="/backup/it-security"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup website files
tar -czf $BACKUP_DIR/website_$DATE.tar.gz /var/www/it-security

# Backup Nginx configuration
tar -czf $BACKUP_DIR/nginx_config_$DATE.tar.gz /etc/nginx

# Backup SSL certificates
tar -czf $BACKUP_DIR/ssl_certs_$DATE.tar.gz /etc/letsencrypt

echo "Backup completed: $DATE"
```

## Troubleshooting

### Common Issues

1. **Port 80/443 not accessible**: Check firewall settings
2. **SSL certificate issues**: Verify domain DNS settings
3. **Nginx won't start**: Check configuration with `sudo nginx -t`
4. **Permission denied**: Verify file ownership and permissions

### Useful Commands

```bash
# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo journalctl -u nginx -f

# Test SSL certificate
openssl s_client -connect your-domain.com:443

# Check certificate expiration
sudo certbot certificates
```

This comprehensive setup provides a production-ready deployment with Nginx, SSL encryption, security hardening, and automated deployment capabilities.
