#!/bin/bash
# A simple script to install TheFuck and integrate it into Zsh for both the current user and root.

# --- Configuration & Helpers ---
USER_HOME="$HOME"
ROOT_HOME="/root"
THEFUCK_ACTIVATION='eval $(thefuck --alias)'

# Define some colors for better output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() {
    echo -e "\n${CYAN}>>> [INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}>>> [SUCCESS] $1${NC}"
}

error_exit() {
    echo -e "${RED}>>> [FATAL ERROR] $1. Exiting.${NC}" >&2
    exit 1
}

# --- Step 1: Install TheFuck using pip3 ---
info "STEP 1: Installing 'thefuck' globally using pip3..."

# Check if pip3 is available and install TheFuck
if command -v pip3 &> /dev/null; then
    # Use '--break-system-packages' to bypass the "externally managed environment" error
    # Use 'sudo -H' to ensure the HOME environment variable isn't polluted during the installation
    if ! sudo -H pip3 install thefuck --break-system-packages; then
        error_exit "Failed to install 'thefuck' via pip3. Check Python/pip installation."
    fi
    success "'thefuck' installed successfully."
else
    # Suggest installation if pip3 is missing
    info "pip3 command not found. Attempting to install python3-pip first..."
    if sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip; then
        # Use '--break-system-packages' after installing pip
        if ! sudo -H pip3 install thefuck --break-system-packages; then
            error_exit "Failed to install 'thefuck' even after installing python3-pip."
        fi
        success "python3-pip and 'thefuck' installed successfully."
    else
        error_exit "Could not install python3-pip. Please ensure your system can install packages."
    fi
fi

# --- Step 2: Configure Current User's Zsh ---
info "STEP 2: Configuring current user's Zsh (~/.zshrc)..."

# Check if the line is already present before appending
if ! grep -qF "$THEFUCK_ACTIVATION" "$USER_HOME/.zshrc" 2> /dev/null; then
    echo -e "\n# TheFuck activation (type 'fuck' after a mistyped command)" >> "$USER_HOME/.zshrc"
    echo "$THEFUCK_ACTIVATION" >> "$USER_HOME/.zshrc"
    success "TheFuck activation added to $USER_HOME/.zshrc."
else
    info "TheFuck activation already found in $USER_HOME/.zshrc. Skipping modification."
fi

# --- Step 3: Configure Root User's Zsh ---
info "STEP 3: Configuring root user's Zsh (/root/.zshrc)..."

# Check if the line is already present before appending (requires sudo for root's file)
if ! sudo grep -qF "$THEFUCK_ACTIVATION" "$ROOT_HOME/.zshrc" 2> /dev/null; then
    # Use sudo tee to append the line to the root-owned file
    echo -e "\n# TheFuck activation (type 'fuck' after a mistyped command)" | sudo tee -a "$ROOT_HOME/.zshrc" > /dev/null
    echo "$THEFUCK_ACTIVATION" | sudo tee -a "$ROOT_HOME/.zshrc" > /dev/null
    success "TheFuck activation added to $ROOT_HOME/.zshrc."
else
    info "TheFuck activation already found in $ROOT_HOME/.zshrc. Skipping modification."
fi

# --- Final Instructions ---
info "--- Setup Complete ---"
info "TheFuck is now installed and configured for both users."
info "To activate the changes, you must source the configuration or restart the shell for each user."
echo -e "\n**For the current user:**"
echo -e "   source ~/.zshrc"
echo -e "\n**For the root user (after running 'sudo su -'):**"
echo -e "   source /root/.zshrc"
echo -e "\nTest it by typing a wrong command (e.g., 'git commti') and then typing 'fuck'!"

exit 0
