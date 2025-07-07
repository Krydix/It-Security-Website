#!/bin/bash

# IT Security Study Guide Deployment Script
# This script builds and deploys the website to GitHub Pages

echo "🚀 Starting deployment process..."

# Check if we're in the right directory
if [ ! -f "docusaurus.config.ts" ]; then
    echo "❌ Error: Not in the correct directory. Please run this script from the project root."
    exit 1
fi

# Install dependencies if needed
echo "📦 Installing dependencies..."
npm install

# Build the website
echo "🏗️ Building the website..."
npm run build

# Deploy to GitHub Pages
echo "🚀 Deploying to GitHub Pages..."
npm run deploy

echo "✅ Deployment completed!"
echo "🌐 Your website will be available at: https://krydix.github.io/It-Security-Website/"
echo "⏳ Note: It may take a few minutes for changes to be visible on GitHub Pages."
