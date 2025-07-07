#!/bin/bash

# IT Security Website Production Deployment Script
# This script automates the deployment process for production servers with Nginx

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/var/www/it-security"
NGINX_CONFIG="/etc/nginx/sites-available/it-security"
DOMAIN="your-domain.com"
WEB_USER="www-data"  # Change to 'nginx' for CentOS/RHEL

# Detect OS and set appropriate web user
if [ -f /etc/redhat-release ]; then
    WEB_USER="nginx"
    NGINX_CONFIG="/etc/nginx/conf.d/it-security.conf"
fi

echo -e "${BLUE}🚀 IT Security Website Production Deployment${NC}"
echo "=============================================="

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   print_warning "Please run as a regular user with sudo privileges"
   exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory $PROJECT_DIR does not exist"
    echo "Please clone the repository first:"
    echo "sudo mkdir -p $PROJECT_DIR"
    echo "sudo chown -R \$USER:\$USER $PROJECT_DIR"
    echo "git clone https://github.com/Krydix/It-Security-Website.git $PROJECT_DIR"
    exit 1
fi

print_status "Project directory found"

# Navigate to project directory
cd $PROJECT_DIR

# Pull latest changes
echo -e "\n${BLUE}📥 Pulling latest changes...${NC}"
if git pull origin main; then
    print_status "Successfully pulled latest changes"
else
    print_error "Failed to pull changes"
    exit 1
fi

# Install dependencies
echo -e "\n${BLUE}📦 Installing dependencies...${NC}"
if npm ci --production; then
    print_status "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Build the project
echo -e "\n${BLUE}🔨 Building project...${NC}"
if npm run build; then
    print_status "Project built successfully"
else
    print_error "Build failed"
    exit 1
fi

# Set permissions
echo -e "\n${BLUE}🔐 Setting permissions...${NC}"
if sudo chown -R $WEB_USER:$WEB_USER $PROJECT_DIR && sudo chmod -R 755 $PROJECT_DIR; then
    print_status "Permissions set successfully"
else
    print_error "Failed to set permissions"
    exit 1
fi

# Test nginx configuration
echo -e "\n${BLUE}🧪 Testing Nginx configuration...${NC}"
if sudo nginx -t; then
    print_status "Nginx configuration is valid"
else
    print_error "Nginx configuration test failed"
    exit 1
fi

# Reload nginx
echo -e "\n${BLUE}🔄 Reloading Nginx...${NC}"
if sudo systemctl reload nginx; then
    print_status "Nginx reloaded successfully"
else
    print_error "Failed to reload Nginx"
    exit 1
fi

# Test website availability
echo -e "\n${BLUE}🌐 Testing website availability...${NC}"
sleep 2
if curl -f -s "https://$DOMAIN" > /dev/null; then
    print_status "Website is accessible"
else
    print_warning "Website test failed - please check manually"
fi

echo -e "\n${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Website is available at: https://$DOMAIN${NC}"

# Optional: Show recent logs
echo -e "\n${BLUE}📝 Recent Nginx access logs:${NC}"
sudo tail -n 5 /var/log/nginx/it-security.access.log 2>/dev/null || echo "No access logs found"

echo -e "\n${BLUE}📋 Deployment Summary:${NC}"
echo "- Repository: Updated to latest version"
echo "- Dependencies: Installed/Updated"
echo "- Build: Completed successfully"
echo "- Permissions: Set correctly"
echo "- Nginx: Configuration tested and reloaded"
echo "- SSL: Certificate should be valid (check with 'sudo certbot certificates')"

echo -e "\n${YELLOW}💡 Useful commands:${NC}"
echo "- Check Nginx status: sudo systemctl status nginx"
echo "- View error logs: sudo tail -f /var/log/nginx/it-security.error.log"
echo "- Test SSL: openssl s_client -connect $DOMAIN:443"
echo "- Check certificates: sudo certbot certificates"
