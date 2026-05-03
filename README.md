# Fedora Post-Install (FPI) Ansible

This project is a modular, automated approach to Fedora post-installation, evolving from a collection of shell scripts into a robust, idempotent Ansible system. It is designed to take a fresh Fedora installation to a fully-configured, production-ready workstation.

## 🏗️ Architecture

The project is organized into **Stages** and **Tasks** for maximum flexibility and readability:

*   **`site.yml`**: The master orchestrator. Use this to run the entire suite.
*   **`tasks/env_setup.yml`**: A centralized "fingerprinting" task that detects your user, home directory, GPU type (NVIDIA/Intel/AMD), and Desktop Environment (GNOME/KDE).
*   **`stage1.yml`**: Initial system optimization (DNF, RPM Fusion, ZSH/Oh-My-Zsh, GRUB).
*   **`stage2.yml`**: Core software and hardware drivers (NVIDIA/MOK, Flatpaks, Codecs, Fonts, VS Code, Brave).
*   **`stage3.yml`**: Gemini CLI extensions and AI toolset integration.

## 🔐 Secrets & Security

To protect sensitive data like MOK passwords and API keys, we use **Ansible Vault**.

### 1. Configure your secrets
Edit `fedora/fpi-ansible/vars/secrets.yml` and add your specific data:
*   `mok_password`: The password used for UEFI/MOK enrollment (default: "fedora").
*   `api_keys`: Your environment variables for AI tools.

### 2. Encrypt your secrets file
Before committing or sharing, encrypt the file:
```bash
ansible-vault encrypt fedora/fpi-ansible/vars/secrets.yml
```

## 🚀 How to Run

### Option A: Quick Start (Bootstrap)
This script will install Ansible, required collections, and prepare the environment.
```bash
cd fedora/fpi-ansible/
./bootstrap.sh
```

### Option B: Manual Run
#### Prerequisite: Install Ansible
```bash
sudo dnf install -y ansible
ansible-galaxy collection install community.general
```

#### Run the Full Orchestration
This will execute all stages in order. Since the secrets are encrypted, you must provide the `--ask-vault-pass` flag.
```bash
ansible-playbook -i fedora/fpi-ansible/inventory.ini fedora/fpi-ansible/site.yml --ask-vault-pass
```

## ✨ New Features
*   **Boolean Stability**: Fixed `is_amd` detection logic to ensure boolean results, preventing deployment crashes on VirtualBox and newer Ansible environments.
*   **Enhanced ZSH**: Now includes `zsh-autosuggestions` and `zsh-syntax-highlighting` by default.
*   **Automated API Keys**: API keys defined in `secrets.yml` are automatically injected into your `.zshrc`.
*   **Specialized Python Tools**: Includes `markitdown` and `notebooklm-py` for AI-powered document processing.

### Run Specific Stages
You can target specific parts of the setup using tags:
```bash
# Run only Stage 1
ansible-playbook -i ... site.yml --ask-vault-pass --tags stage1

# Run only NVIDIA/Hardware tasks
ansible-playbook -i ... site.yml --ask-vault-pass --tags hardware
```

## ⚠️ Important Notes
*   **Rebooting**: Some tasks (like kernel updates or NVIDIA drivers) require a reboot. It is recommended to reboot between Stage 1 and Stage 2 if a kernel update was performed.
*   **Secure Boot**: When installing NVIDIA drivers, you will be prompted to enroll the MOK key on the next reboot. Use the password defined in your `secrets.yml`.
*   **Idempotency**: All tasks are designed to be safe to run multiple times. They will only make changes if the system is not already in the desired state.

---
*Maintained with the assistance of **Axis (Universal Linux Specialist)**.*
