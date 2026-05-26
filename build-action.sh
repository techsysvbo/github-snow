#!/bin/bash
# 🧒 7-year-old explanation:
# This takes our robot code and packages it into a single file that GitHub can run.
# It's like putting all your toys in one box so you can carry them easily.

# 🎯 SME explanation:
# Compiles the GitHub Action using @vercel/ncc to create a single JavaScript bundle.
# This improves performance, reduces install time, and eliminates runtime dependencies.

set -e

echo "🔨 Building Snow GitHub App Action..."

cd .github/actions/snow-github-app

# Install dependencies
npm ci --production=false

# Run tests
npm test

# Bundle with ncc
npx @vercel/ncc build index.js -o dist

# Copy package.json for action metadata
cp package.json dist/

# Verify the bundle works
node -e "require('./dist/index.js')" || {
  echo "❌ Build verification failed"
  exit 1
}

echo "✅ Action built successfully in dist/"
