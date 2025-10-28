#!/bin/bash
# Enable command tracing (x), exit on error (e), and exit on unset variable (u)
set -eux

# === Color Defs & Helpers ===
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m' # Added for warn function
NC='\033[0m'

info() {
    echo -e "\n${CYAN}>>> [INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}>>> [SUCCESS] $1${NC}"
}

warn() { # Added missing warn function
    echo -e "${YELLOW}>>> [WARNING] $1${NC}" >&2
}

error_exit() {
    echo -e "${RED}>>> [FATAL ERROR] $1. Exiting.${NC}" >&2
    exit 1
}

# ---
# SCRIPT START: Pre-flight checks and preparation
# ---
info "STARTING Zsh Setup (Diagnostic Mode)..."
USER_NAME=$(whoami)
USER_HOME=$HOME
ROOT_HOME="/root"

# ---
# STEP 1: Dependencies Installation
# ---
info "STEP 1: Installing base dependencies (zsh, git, fzf, tools)..."
# Use DEBIAN_FRONTEND=noninteractive to prevent prompts
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  zsh \
    curl \
    git \
    fzf \
    python3-pip \
    bash-completion \
    open-vm-tools-desktop || \
error_exit "APT installation failed"

# Add zsh to legal shells
if ! grep -q "$(which zsh)" /etc/shells;
then
    info "Adding Zsh to /etc/shells."
    echo "$(which zsh)" | \
sudo tee -a /etc/shells > /dev/null
fi
success "Dependencies installed."

# ---
# STEP 2: Oh My Zsh and Plugin Installation
# ---

# Function to handle OMZ and plugin cloning
setup_user_plugins() {
    local USER_DIR=$1
    local SUDO_PREFIX=$2
    local ZSH_DIR="$USER_DIR/.oh-my-zsh"
    local CUSTOM_DIR="$ZSH_DIR/custom"
    local AC_DIR="$USER_DIR/.zsh/zsh-autocomplete"

    info "Setting up OMZ and plugins for $USER_DIR"

    # 1. Install Oh My Zsh
    if [ ! -d "$ZSH_DIR" ]; then
        $SUDO_PREFIX git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" || \
error_exit "OMZ clone failed for $USER_DIR"
    else
        info "Oh My Zsh already exists in $ZSH_DIR. Skipping clone."
    fi

    # 2. Create custom directory (Needs sudo for /root)
    $SUDO_PREFIX mkdir -p "$CUSTOM_DIR/plugins"

    # 3. Clone mandatory plugins
    clone_or_skip() {
        local REPO_URL=$1
        local DEST_DIR=$2
        if [ ! -d "$DEST_DIR" ]; then
            $SUDO_PREFIX git clone --depth=1 "$REPO_URL" "$DEST_DIR" || \
error_exit "Plugin clone failed for $(basename $DEST_DIR)"
        else
            info "$(basename $DEST_DIR) already exists. Skipping clone."
        fi
    }

    clone_or_skip "https://github.com/zsh-users/zsh-autosuggestions.git" "$CUSTOM_DIR/plugins/zsh-autosuggestions"
    clone_or_skip "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    clone_or_skip "https://github.com/Aloxaf/fzf-tab.git" "$CUSTOM_DIR/plugins/fzf-tab"
    
    # 4. Clone Autocomplete (uses a different path convention)
    $SUDO_PREFIX mkdir -p "$AC_DIR"
    clone_or_skip "https://github.com/marlonrichert/zsh-autocomplete.git" "$AC_DIR"
    
    # 5. Fix permissions if running as sudo (only needed for /root setup)
    if [ "$SUDO_PREFIX" = "sudo" ];
    then
        info "Fixing permissions for $USER_DIR."
        sudo chown -R root:root "$ZSH_DIR" "$AC_DIR"
    fi
}

# Setup for Normal User
setup_user_plugins "$USER_HOME" ""

# Setup for Root User
setup_user_plugins "$ROOT_HOME" "sudo"
success "All plugins cloned successfully."

# ---
# STEP 3: Create and Write Portable .zshrc
# ---
info "STEP 3: Creating and distributing portable .zshrc..."

# Use a multi-line echo piped to tee to write the content directly.
# This avoids the troublesome Here-Document assignment to a variable.

# Write for User (piped to tee for better formatting control)
echo '
# === Zsh Configuration: Portable for User & Root ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
ZDOTDIR=${ZDOTDIR:-$HOME}

# Theme and general settings
ZSH_THEME="kali"
plugins=() # Manual sourcing below

# --- History Settings ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# --- Aliases ---
alias ll='"'"'ls -alF'"'"'
alias l='"'"'ls -CF'"'"'
alias la='"'"'ls -A'"'"'
alias gs='"'"'git status'"'"'
alias grep='"'"'grep --color=auto'"'"'
alias ..='"'"'cd ..'"'"'
alias ...='"'"'cd ../..'"'"'

# --- Source Oh My Zsh ---
if [ -f "$ZSH/oh-my-zsh.sh" ];
then
    source "$ZSH/oh-my-zsh.sh"
fi

# --- Load Plugins (Sourced Manually) ---
# 1. zsh-autosuggestions
if [ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. zsh-syntax-highlighting (Must be sourced last for visual effects)
if [ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# 3. zsh-autocomplete
if [ -f "$ZDOTDIR/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ];
then
    source "$ZDOTDIR/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

# 4. fzf-tab
if [ -f "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh"
    zstyle '"'"':completion:*:*'"'"' fzf-preview 1
fi

# --- fzf Keybindings (Ctrl+R History Search) ---
if [ -f /usr/share/fzf/key-bindings.zsh ];
then
    source /usr/share/fzf/key-bindings.zsh
fi
' | tee "$USER_HOME/.zshrc" > /dev/null

# Write for Root (using sudo tee)
echo '
# === Zsh Configuration: Portable for User & Root ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
ZDOTDIR=${ZDOTDIR:-$HOME}

# Theme and general settings
ZSH_THEME="kali"
plugins=() # Manual sourcing below

# --- History Settings ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# --- Aliases ---
alias ll='"'"'ls -alF'"'"'
alias l='"'"'ls -CF'"'"'
alias la='"'"'ls -A'"'"'
alias gs='"'"'git status'"'"'
alias grep='"'"'grep --color=auto'"'"'
alias ..='"'"'cd ..'"'"'
alias ...='"'"'cd ../..'"'"'

# --- Source Oh My Zsh ---
if [ -f "$ZSH/oh-my-zsh.sh" ];
then
    source "$ZSH/oh-my-zsh.sh"
fi

# --- Load Plugins (Sourced Manually) ---
# 1. zsh-autosuggestions
if [ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. zsh-syntax-highlighting (Must be sourced last for visual effects)
if [ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# 3. zsh-autocomplete
if [ -f "$ZDOTDIR/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ];
then
    source "$ZDOTDIR/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

# 4. fzf-tab
if [ -f "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh" ];
then
    source "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh"
    zstyle '"'"':completion:*:*'"'"' fzf-preview 1
fi

# --- fzf Keybindings (Ctrl+R History Search) ---
if [ -f /usr/share/fzf/key-bindings.zsh ];
then
    source /usr/share/fzf/key-bindings.zsh
fi
' | sudo tee "$ROOT_HOME/.zshrc" > /dev/null

success ".zshrc files written to $USER_HOME and $ROOT_HOME."

# ---
# STEP 4: Change Default Shells
# ---
info "STEP 4: Setting Zsh as the default shell..."

# Change for User
if ! sudo chsh -s "$(which zsh)" "$USER_NAME"; then
    warn "Failed to change shell for $USER_NAME. You may need to run 'chsh -s $(which zsh)' manually."
fi

# Change for Root
if ! sudo chsh -s "$(which zsh)" root;
then
    warn "Failed to change shell for root. You may need to run 'sudo chsh -s $(which zsh) root' manually."
fi
success "Default shells set."

# ---
# SCRIPT END: Summary
# ---
info "SETUP COMPLETE! Please re-read the instructions below."
echo -e "\n${GREEN}### SCRIPT FINISHED SUCCESSFULLY ###${NC}"
info "The script traced every command. If it was stuck, the last printed line before the hang is the culprit."
