# MANUALLY INSTALL THE FUCK WITH:
```sudo pip3 install thefuck --break-system-packages```

After this, just use the following script to enter all the aliases, etc:

```
#!/bin/bash
# Script to add TheFuck activation to Zsh config files for the current user and root.

# --- Configuration ---
USER_HOME="$HOME"
ROOT_HOME="/root"
THEFUCK_ACTIVATION='eval $(thefuck --alias)'

# --- Helpers ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

info() {
    echo -e "\n${CYAN}>>> [INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}>>> [SUCCESS] $1${NC}"
}

# --- Step 1: Configure Current User's Zsh ---
info "STEP 1: Configuring current user's Zsh (~/.zshrc)..."

# Check if the line is already present before appending
if ! grep -qF "$THEFUCK_ACTIVATION" "$USER_HOME/.zshrc" 2> /dev/null; then
    echo -e "\n# TheFuck activation (type 'fuck' after a mistyped command)" >> "$USER_HOME/.zshrc"
    echo "$THEFUCK_ACTIVATION" >> "$USER_HOME/.zshrc"
    success "TheFuck activation added to $USER_HOME/.zshrc."
else
    info "TheFuck activation already found in $USER_HOME/.zshrc. Skipping modification."
fi

# --- Step 2: Configure Root User's Zsh ---
info "STEP 2: Configuring root user's Zsh (/root/.zshrc)..."

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
info "--- Configuration Complete ---"
info "TheFuck is now configured for both users."
info "To activate the changes, you must source the configuration or restart the shell for each user."
echo -e "\n**For the current user:**"
echo -e "   source ~/.zshrc"
echo -e "\n**For the root user (after running 'sudo su -'):**"
echo -e "   source /root/.zshrc"
echo -e "\nTest it by typing a wrong command (e.g., 'apt-get updtae') and then typing 'fuck'!"

exit 0

```
