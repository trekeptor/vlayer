#!/bin/bash

# Exit on any error
set -e

# Function to determine template based on script name
get_template() {
    case "$(basename "$0")" in
        setup-email-proof.sh)
            echo "simple-email-proof"
            ;;
        setup-teleport.sh)
            echo "simple-teleport"
            ;;
        setup-time-travel.sh)
            echo "simple-time-travel"
            ;;
        setup-web-proof.sh)
            echo "simple-web-proof"
            ;;
        *)
            echo "Error: Unknown script name. Use one of: setup-email-proof.sh, setup-teleport.sh, setup-time-travel.sh, setup-web-proof.sh"
            exit 1
            ;;
    esac
}

# Get the template name
TEMPLATE=$(get_template)
PROJECT_DIR="my-${TEMPLATE#simple-}"  # e.g., my-email-proof from simple-email-proof

# GitHub repo URL (replace with your actual repo URL)
GITHUB_REPO="https://github.com/YOUR_USERNAME/YOUR_REPO.git"

echo "🔧 Setting up vLayer project for $TEMPLATE..."

# Clone the GitHub repo
if [ -d "$PROJECT_DIR" ]; then
    echo "Directory $PROJECT_DIR already exists. Skipping clone."
else
    echo "Cloning repository from $GITHUB_REPO..."
    git clone "$GITHUB_REPO" "$PROJECT_DIR"
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Install dependencies (only if not already installed)
echo "🔧 Installing dependencies..."

# Core system deps
sudo apt-get update && sudo apt-get install -y git curl unzip build-essential

# Install Foundry
if ! command -v forge &> /dev/null; then
    curl -L https://foundry.paradigm.xyz/ | bash
    source ~/.bashrc
    foundryup
else
    echo "Foundry already installed."
fi

# Install Bun
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    source ~/.profile
else
    echo "Bun already installed."
fi

# Install vLayer CLI
if ! command -v vlayer &> /dev/null; then
    curl -SL https://install.vlayer.xyz/ | bash
    source ~/.bashrc
    vlayerup
else
    echo "vLayer CLI already installed."
fi

echo "✅ Dependencies installed."

# Initialize vLayer project (skip if already initialized)
if [ ! -f "foundry.toml" ]; then
    echo "Initializing vLayer project with template $TEMPLATE..."
    vlayer init --template "$TEMPLATE"
else
    echo "vLayer project already initialized."
fi

# Build the project
echo "Building project..."
forge build

# Navigate to vlayer directory
cd vlayer

# Install Bun dependencies
echo "Installing Bun dependencies..."
bun install

# Prompt for API token and private key
echo "Please enter your vLayer API Token (get it from https://dashboard.vlayer.xyz/):"
read -r VLAYER_API_TOKEN
echo

echo "Please enter your private key (starting with 0x):"
read -r EXAMPLES_TEST_PRIVATE_KEY
echo

# Create .env.testnet.local file with inputs
echo "Creating environment file..."
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

echo "✅ Setup complete for $TEMPLATE!"
