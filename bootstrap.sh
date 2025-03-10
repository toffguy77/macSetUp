#!/bin/bash
# Purpose:
#	* bootstrap machine in order to prepare for ansible playbook run

set -e

echo "========================================================"
echo "Starting macOS system setup bootstrap process"
echo "This script will prepare your system for Ansible playbook execution"
echo "========================================================"
echo
# Download and install Command Line Tools if no developer tools exist
echo "Checking for Xcode Command Line Tools..."
if [[ $(/usr/bin/gcc 2>&1) =~ "no developer tools were found" ]] || [[ ! -x /usr/bin/gcc ]]; then
    echo "Command Line Tools not found. Installing Xcode Command Line Tools..."
    echo "This may take several minutes and may require a restart."
    softwareupdate --all --install --force --restart || exit 1
    echo "✅ Xcode Command Line Tools installation complete."
else
    echo "✅ Xcode Command Line Tools already installed. Skipping."
fi
echo

# Download and install Homebrew
# Check both Intel and Apple Silicon Mac Homebrew paths
echo "Checking for Homebrew installation..."
if [[ ! -x /usr/local/bin/brew ]] && [[ ! -x /opt/homebrew/bin/brew ]]; then
    echo "Homebrew not found. Installing Homebrew package manager..."
    echo "This will install Homebrew to /usr/local (Intel Macs) or /opt/homebrew (Apple Silicon Macs)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✅ Homebrew installation complete."
else
    echo "✅ Homebrew already installed. Skipping."
fi
echo

# Download and install Ansible
# Check both Intel and Apple Silicon Mac Ansible paths
echo "Checking for Ansible installation..."
if [[ ! -x /usr/local/bin/ansible ]] && [[ ! -x /opt/homebrew/bin/ansible ]]; then
    echo "Ansible not found. Installing Ansible using Homebrew..."
    brew install ansible
    echo "✅ Ansible installation complete."
else
    echo "✅ Ansible already installed. Skipping."
fi
echo

echo "Installing/updating required Ansible collections..."
echo "Installing community.general collection to ~/.ansible/collections..."
ansible-galaxy collection install community.general -p ~/.ansible/collections --force
echo "✅ Ansible collections installation complete."
echo

# Modify the PATH
# Add both Intel and Apple Silicon Homebrew paths
echo "Updating PATH to include Homebrew binary paths..."
export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
echo "✅ PATH updated to include Homebrew binaries."
echo

echo "========================================================"
echo "Bootstrap process complete!"
echo "Now running Ansible playbook to configure your system."
echo "You will be prompted for your sudo password."
echo "This process will install and configure various software packages,"
echo "development tools, and system settings according to the playbook."
echo "========================================================"
echo

ansible-playbook local.yml -K

echo
echo "========================================================"
echo "System setup complete! Your Mac has been configured with:"
echo "- Developer tools and programming languages"
echo "- Applications and utilities"
echo "- Shell configuration (Zsh)"
echo "- macOS system preferences"
echo "========================================================"
