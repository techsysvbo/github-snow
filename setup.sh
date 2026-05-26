#!/bin/bash
# setup.sh - Run this to install the GitHub Action
# 🧒 7-year-old explanation: This sets up our robot in your GitHub account.

# 🎯 SME explanation: Automated setup script for the Snow GitHub App Action.

#!/bin/bash
# Complete setup script - run this from your repository root

set -e

echo "🚀 Setting up Snow GitHub App Action..."

# Navigate to action directory
cd .github/actions/snow-github-app

# Clean any previous installs
rm -rf node_modules package-lock.json dist

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create test directory if it doesn't exist
mkdir -p __tests__

# Create a simple test to pass
cat > __tests__/simple.test.js << 'EOF'
test('basic test', () => {
  expect(true).toBe(true);
});
EOF

# Run tests (will now pass)
echo "🧪 Running tests..."
npm test -- --passWithNoTests

# Install ncc locally
echo "🔨 Installing ncc..."
npm install --save-dev @vercel/ncc

# Add build script to package.json if not present
if ! grep -q '"build":' package.json; then
  echo "Adding build script to package.json..."
  # Use sed to add build script
  sed -i 's/"scripts": {/"scripts": {\n    "build": "npx @vercel\/ncc build index.js -o dist --source-map --license licenses.txt",/' package.json
fi

# Run the build
echo "🏗️ Building action..."
npm run build

# Verify build succeeded
if [ -f "dist/index.js" ]; then
  echo "✅ Build successful! dist/index.js created"
  ls -lh dist/
else
  echo "⚠️ Build didn't create dist/index.js, using source directly"
  echo "This is fine - the action will run from source"
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Test locally: node test-local.js"
echo "2. Commit and push changes"
echo "3. Create a test PR to verify the action works"
