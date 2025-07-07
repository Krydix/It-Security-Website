#!/bin/bash

# IT Security Website Production Setup Script
# This script helps set up the production environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 IT Security Website Production Setup${NC}"
echo "========================================"

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get user input
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter your email for Let's Encrypt: " EMAIL
read -p "Choose deployment method (nginx/docker): " DEPLOY_METHOD

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    print_error "Domain and email are required"
    exit 1
fi

echo -e "\n${BLUE}📋 Configuration Summary:${NC}"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Deployment: $DEPLOY_METHOD"

read -p "Is this correct? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

# Update configuration files based on deployment method
if [ "$DEPLOY_METHOD" = "nginx" ]; then
    echo -e "\n${BLUE}📝 Configuring Nginx deployment...${NC}"
    
    # Update deployment script
    if [ -f "deploy-production.sh" ]; then
        sed -i "s/your-domain.com/$DOMAIN/g" deploy-production.sh
        print_status "Updated deployment script"
    fi
    
    # Create nginx configuration
    cat > nginx-site.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # Document root
    root /var/www/it-security/build;
    index index.html;
    
    # SSL Configuration (will be added by Certbot)
    # ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
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
        try_files \$uri =404;
    }
    
    # Handle routes (for SPA)
    location / {
        try_files \$uri \$uri/ /index.html;
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
EOF
    
    print_status "Created nginx configuration file: nginx-site.conf"
    
    echo -e "\n${YELLOW}📖 Next steps for Nginx deployment:${NC}"
    echo "1. Copy nginx-site.conf to your server"
    echo "2. Place it in /etc/nginx/sites-available/it-security"
    echo "3. Enable the site: sudo ln -s /etc/nginx/sites-available/it-security /etc/nginx/sites-enabled/"
    echo "4. Test config: sudo nginx -t"
    echo "5. Restart nginx: sudo systemctl restart nginx"
    echo "6. Get SSL certificate: sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
    echo "7. Run the deployment script: ./deploy-production.sh"

elif [ "$DEPLOY_METHOD" = "docker" ]; then
    echo -e "\n${BLUE}🐳 Configuring Docker deployment...${NC}"
    
    # Update docker-compose
    if [ -f "docker-compose.production.yml" ]; then
        sed -i "s/your-domain.com/$DOMAIN/g" docker-compose.production.yml
        sed -i "s/your-email@example.com/$EMAIL/g" docker-compose.production.yml
        print_status "Updated docker-compose configuration"
    fi
    
    # Create docker deployment script
    cat > deploy-docker.sh << 'EOF'
#!/bin/bash

echo "🐳 Deploying with Docker..."

# Build and start the containers
docker-compose -f docker-compose.production.yml up -d --build

echo "✅ Docker deployment completed!"
echo "🌐 Your website should be available at: http://$DOMAIN"
echo "⏰ SSL certificates will be automatically obtained"

# Show container status
docker-compose -f docker-compose.production.yml ps
EOF
    
    chmod +x deploy-docker.sh
    print_status "Created Docker deployment script"
    
    echo -e "\n${YELLOW}📖 Next steps for Docker deployment:${NC}"
    echo "1. Make sure Docker and Docker Compose are installed"
    echo "2. Point your domain to your server's IP address"
    echo "3. Run: ./deploy-docker.sh"
    echo "4. Monitor with: docker-compose -f docker-compose.production.yml logs -f"

else
    print_error "Invalid deployment method. Choose 'nginx' or 'docker'"
    exit 1
fi

# Make deployment scripts executable
chmod +x deploy-production.sh 2>/dev/null || true
chmod +x deploy-docker.sh 2>/dev/null || true

echo -e "\n${GREEN}✅ Setup completed successfully!${NC}"
echo -e "${BLUE}📖 Don't forget to:${NC}"
echo "- Point your domain DNS to your server's IP address"
echo "- Open ports 80 and 443 in your firewall"
echo "- Ensure your server has enough resources (1GB RAM minimum)"

echo -e "\n${YELLOW}📚 For detailed instructions, see: docs/production-deployment.md${NC}"
