#!/bin/bash

# Exit on any error
set -e

echo "🔧 Installing dependencies..."

# Core system deps
sudo apt-get update && sudo apt-get install -y git curl unzip build-essential

# Install Foundry
curl -L https://foundry.paradigm.xyz/ | bash
source ~/.bashrc
foundryup

# Install Bun
curl -fsSL https://bun.sh/install | bash
source ~/.profile

# Install vLayer CLI
curl -SL https://install.vlayer.xyz/ | bash
source ~/.bashrc
vlayerup

echo "✅ Dependencies installed."

# Print instructions
echo "Setting up vLayer email proof project..."

# Create directory and navigate
mkdir my-simple-time-travel
cd my-simple-time-travel

# Initialize vlayer project
vlayer init --template simple-time-travel

# Build the project
forge build

# Navigate to vlayer directory
cd vlayer

# Install dependencies
bun install

# Prompt for API token and private key
echo "Please enter your vLayer API Token (get it from https://dashboard.vlayer.xyz/):"
read  VLAYER_API_TOKEN
echo

echo "Please enter your private key (starting with 0x):"
read  EXAMPLES_TEST_PRIVATE_KEY
echo

# Create .env.testnet.local file with inputs
cat > .env.testnet.local << EOL
VLAYER_API_TOKEN=$VLAYER_API_TOKEN
EXAMPLES_TEST_PRIVATE_KEY=$EXAMPLES_TEST_PRIVATE_KEY
CHAIN_NAME=optimismSepolia
JSON_RPC_URL=https://sepolia.optimism.io
EOL

echo "Environment file created at .env.testnet.local"

# Run the prove command
echo "Running prove:testnet..."
bun run prove:testnet

echo "Setup complete!"
