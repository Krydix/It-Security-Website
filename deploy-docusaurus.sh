#!/bin/bash

# Docusaurus Deployment Script
# This script builds and deploys your Docusaurus site

set -e

# Configuration (UPDATE THESE PATHS)
DOCUSAURUS_DIR="/path/to/your/docusaurus/project"
WEBSITE_DIR="/var/www/yourdomain.com"
DOMAIN="yourdomain.com"

echo "🚀 Deploying Docusaurus site..."

# Change to the Docusaurus project directory
cd "$DOCUSAURUS_DIR"

# Install/update dependencies
echo "📦 Installing dependencies..."
npm ci

# Build the site
echo "🔨 Building Docusaurus site..."
npm run build

# Check if build was successful
if [ ! -d "build" ]; then
    echo "❌ Build failed - no build directory found"
    exit 1
fi

echo "✅ Build completed successfully"

# Copy files to web server directory (requires sudo)
echo "📋 Deploying files to web server..."
sudo rm -rf $WEBSITE_DIR/*
sudo cp -r build/* $WEBSITE_DIR/
sudo chown -R www-data:www-data $WEBSITE_DIR
sudo chmod -R 755 $WEBSITE_DIR

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
sudo nginx -t

# Reload nginx to pick up any changes
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Your site is live at: https://$DOMAIN"
echo ""
