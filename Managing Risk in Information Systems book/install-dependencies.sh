#!/bin/bash
# install-dependencies.sh
# Script to install all dependencies required for the Markdown to Common Cartridge converter
# For Debian 12 systems

# Exit on error
set -e

echo "Installing dependencies for Markdown to Common Cartridge converter..."

# Function to install a package if it's not already installed
install_package() {
  local package_name="$1"
  local binary_name="${2:-$1}"  # Use package name as binary name if not specified
  
  if ! command -v "$binary_name" &> /dev/null; then
    echo "Installing $package_name..."
    sudo apt-get install -y "$package_name"
  else
    echo "$package_name is already installed."
  fi
}

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install standard packages
install_package "pandoc"
install_package "zip"
install_package "xmlstarlet"
install_package "uuid-runtime" "uuidgen"

# Install yq (YAML processor) - not available in standard repos
if ! command -v yq &> /dev/null; then
  echo "Installing yq (YAML processor)..."
  # Make sure wget is installed
  install_package "wget"
  
  # Download and install yq
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod +x /usr/local/bin/yq
  
  # Verify installation
  if ! command -v yq &> /dev/null; then
    echo "ERROR: Failed to install yq"
    exit 1
  else
    echo "yq installed successfully."
  fi
else
  echo "yq is already installed."
fi

echo "All dependencies have been installed successfully."
echo "You can now run the md-to-cc-converter.sh script."
