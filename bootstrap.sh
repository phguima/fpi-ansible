#!/bin/bash

# Fedora Post-Install (FPI) Ansible Bootstrap Script
# This script prepares the system to run the Ansible playbooks.

set -e

C_RESET='\033[0m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'

prompt() {
    echo -e "${C_BLUE}==>${C_RESET} $1"
}

success() {
    echo -e "${C_GREEN}SUCCESS:${C_RESET} $1"
}

warn() {
    echo -e "${C_YELLOW}WARNING:${C_RESET} $1"
}

error() {
    echo -e "${C_RED}ERROR:${C_RESET} $1"
}

# 1. Install Ansible if not present
if ! command -v ansible &> /dev/null; then
    prompt "Installing Ansible..."
    sudo dnf install -y ansible
else
    success "Ansible is already installed."
fi

# 2. Install required Ansible collections
prompt "Installing required Ansible collections..."
ansible-galaxy collection install community.general

# 3. Check for secrets file
if [ ! -f "vars/secrets.yml" ]; then
    warn "vars/secrets.yml not found. Creating a template..."
    mkdir -p vars
    cat <<EOF > vars/secrets.yml
---
# NVIDIA / MOK Settings
mok_password: "fedora"

# Gemini CLI / API Keys
api_keys: |
  # export GEMINI_API_KEY="your-key-here"
  # export GOOGLE_API_KEY="your-key-here"
EOF
    prompt "Please edit vars/secrets.yml with your data before running the playbook."
fi

# 4. Instructions
echo ""
prompt "Bootstrap complete! You can now run the playbook using:"
echo -e "${C_GREEN}ansible-playbook -i inventory.ini site.yml --ask-vault-pass${C_RESET}"
echo ""
warn "Note: If your secrets.yml is NOT yet encrypted, you can skip --ask-vault-pass or encrypt it now with:"
echo -e "${C_YELLOW}ansible-vault encrypt vars/secrets.yml${C_RESET}"
