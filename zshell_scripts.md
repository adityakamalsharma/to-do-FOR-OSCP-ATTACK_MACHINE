Here is the complete, single-script guide to setting up your Zsh environment on a fresh Kali Linux VM for
both your normal user and root.

This script is designed to be **idempotent**, meaning it's safe to re-run at any time without breaking your configuration.

-----

### 🚀 The Automated Setup Script

Copy the entire block below into a file (e.g., `setup_zsh.sh`), make it executable (`chmod +x setup_zsh.sh`), and run it as your normal user (`./setup_zsh.sh`).

```bash
#!/bin/bash
set -e

# === Color Defs ===
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# === Helper Functions ===
info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error_exit() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Function to clone a git repo if the directory doesn't exist
clone_repo() {
    local repo_url=$1
    local dest_dir=$2
    local sudo_prefix=${3:-} # Optional sudo prefix

    if [ ! -d "$dest_dir" ]; then
        info "Cloning $(basename $dest_dir)..."
        if ! $sudo_prefix git clone --depth=1 "$repo_url" "$dest_dir"; then
            error_exit "Failed to clone $repo_url"
        fi
    else
        info "$(basename $dest_dir) already exists. Skipping clone."
    fi
}

# === Start Setup ===
info "Starting Zsh & Oh My Zsh setup for USER and ROOT..."
info "This script will use 'sudo' to install packages and configure the root account."

# === 1. Install Dependencies ===
info "Updating package lists and installing dependencies..."
if ! sudo apt-get update; then
    error_exit "Failed to update apt package lists."
fi

if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zsh \
    curl \
    git \
    fzf \
    python3-pip \
    python3-dev \
    python3-setuptools \
    bash-completion \
    open-vm-tools-desktop; then
    error_exit "Failed to install base dependencies."
fi

# Ensure /usr/bin/zsh is in /etc/shells
if ! grep -q "$(which zsh)" /etc/shells; then
    info "Adding $(which zsh) to /etc/shells"
    echo "$(which zsh)" | sudo tee -a /etc/shells
fi

# === 2. Install 'thefuck' (Optional) ===
info "Installing 'thefuck' via pip3..."
if ! sudo pip3 install -U thefuck; then
    warn "Failed to install 'thefuck'. Continuing without it."
fi

# === 3. Define .zshrc Configuration ===
# We define this ONCE. Using 'EOF' (with single quotes) prevents
# $HOME from being expanded by bash, allowing zsh to expand it at runtime.
# This makes the file perfectly portable between /home/user and /root.

read -r -d '' ZSHRC_CONTENT <<'EOF'
# === Oh My Zsh Config ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# "kali" is clean and functional.
ZSH_THEME="kali"

# Standard ZSH_CUSTOM location
export ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Disable Oh My Zsh's built-in plugin loading to speed up startup
# We will source plugins manually for better control.
plugins=()

# === History Settings ===
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# === Source Oh My Zsh ===
# This MUST come before sourcing custom plugins
# But AFTER setting theme and plugin variables.
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "[ERROR] Oh My Zsh not found at $ZSH" >&2
fi

# === Load Plugins (Manual Sourcing) ===
# We source them in the recommended order.

# 1. zsh-autosuggestions (Suggests commands as you type)
if [ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. zsh-syntax-highlighting (Highlights commands)
# *MUST* be sourced at the end, or at least after autosuggestions.
if [ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# 3. zsh-autocomplete (Marlon Richert's powerful autocomplete)
# Sourced *before* fzf-tab
if [ -f "${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
    source "${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

# 4. fzf-tab (Use fzf for tab completions)
# Sourced *after* zsh-autocomplete
if [ -f "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Optional: configure fzf-tab
    zstyle ':completion:*:*' fzf-preview 1
fi

# === fzf Keybindings (from apt package) ===
# This enables Ctrl+R history search
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
fi

# === Aliases ===
alias ll='ls -alF'
alias l='ls -CF'
alias la='ls -A'
alias gs='git status'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# === 'thefuck' Alias (Optional) ===
# Uncomment the line below if you installed 'thefuck' and want to use it.
# eval $(thefuck --alias)

EOF

# === 4. Setup for Current USER ===
info "Setting up Zsh for current user ($USER)..."
USER_HOME=$HOME
USER_ZSH=$USER_HOME/.oh-my-zsh
USER_ZSH_CUSTOM=$USER_ZSH/custom
USER_ZSH_AUTOCOMPLETE=$USER_HOME/.zsh/zsh-autocomplete

# Install Oh My Zsh for USER
clone_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$USER_ZSH"

# Install Plugins for USER
sudo mkdir -p "$USER_ZSH_CUSTOM/plugins"
clone_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$USER_ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$USER_ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_repo "https://github.com/Aloxaf/fzf-tab.git" "$USER_ZSH_CUSTOM/plugins/fzf-tab"

# Install zsh-autocomplete for USER
sudo mkdir -p "$USER_ZSH_AUTOCOMPLETE"
clone_repo "https://github.com/marlonrichert/zsh-autocomplete.git" "$USER_ZSH_AUTOCOMPLETE"

# Fix user permissions (git clone as user, but mkdir as sudo)
info "Fixing permissions for $USER_HOME..."
if ! sudo chown -R "$USER:$USER" "$USER_HOME/.oh-my-zsh" "$USER_HOME/.zsh"; then
    warn "Could not chown user directories. This might be fine."
fi

# Write .zshrc for USER
info "Writing $USER_HOME/.zshrc..."
echo "$ZSHRC_CONTENT" > "$USER_HOME/.zshrc"

# Change default shell for USER
if [ "$(basename "$SHELL")" != "zsh" ]; then
    info "Changing default shell to zsh for $USER..."
    if ! sudo chsh -s "$(which zsh)" "$USER"; then
        error_exit "Failed to change shell for $USER."
    fi
else
    info "Default shell for $USER is already zsh."
fi
success "User setup complete."

# === 5. Setup for ROOT ===
info "Setting up Zsh for ROOT user..."
ROOT_HOME=/root
ROOT_ZSH=$ROOT_HOME/.oh-my-zsh
ROOT_ZSH_CUSTOM=$ROOT_ZSH/custom
ROOT_ZSH_AUTOCOMPLETE=$ROOT_HOME/.zsh/zsh-autocomplete

# Install Oh My Zsh for ROOT
clone_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$ROOT_ZSH" "sudo"

# Install Plugins for ROOT
sudo mkdir -p "$ROOT_ZSH_CUSTOM/plugins"
clone_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ROOT_ZSH_CUSTOM/plugins/zsh-autosuggestions" "sudo"
clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ROOT_ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "sudo"
clone_repo "https://github.com/Aloxaf/fzf-tab.git" "$ROOT_ZSH_CUSTOM/plugins/fzf-tab" "sudo"

# Install zsh-autocomplete for ROOT
sudo mkdir -p "$ROOT_ZSH_AUTOCOMPLETE"
clone_repo "https://github.com/marlonrichert/zsh-autocomplete.git" "$ROOT_ZSH_AUTOCOMPLETE" "sudo"

# Write .zshrc for ROOT
info "Writing $ROOT_HOME/.zshrc..."
echo "$ZSHRC_CONTENT" | sudo tee "$ROOT_HOME/.zshrc" > /dev/null

# Change default shell for ROOT
if [ "$(sudo awk -F: -v user=root '$1 == user {print $NF}' /etc/passwd)" != "$(which zsh)" ]; then
    info "Changing default shell to zsh for root..."
    if ! sudo chsh -s "$(which zsh)" root; then
        error_exit "Failed to change shell for root."
    fi
else
    info "Default shell for root is already zsh."
fi
success "Root setup complete."

# === 6. Final Steps ===
success "All done!"
info "Please log out and log back in (or restart your terminal) for all changes to take effect."
info "Your default shell is now Zsh for both $USER and root."

```

-----

### ⚙️ Final `.zshrc` Configuration Files

The script above generates the *exact same* file for both user and root. This is the intended behavior, as the file uses variables like `$HOME` which Zsh expands correctly for whichever user is active.

#### `~/.zshrc` (User)

```zsh
# === Oh My Zsh Config ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# "kali" is clean and functional.
ZSH_THEME="kali"

# Standard ZSH_CUSTOM location
export ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Disable Oh My Zsh's built-in plugin loading to speed up startup
# We will source plugins manually for better control.
plugins=()

# === History Settings ===
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# === Source Oh My Zsh ===
# This MUST come before sourcing custom plugins
# But AFTER setting theme and plugin variables.
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "[ERROR] Oh My Zsh not found at $ZSH" >&2
fi

# === Load Plugins (Manual Sourcing) ===
# We source them in the recommended order.

# 1. zsh-autosuggestions (Suggests commands as you type)
if [ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. zsh-syntax-highlighting (Highlights commands)
# *MUST* be sourced at the end, or at least after autosuggestions.
if [ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# 3. zsh-autocomplete (Marlon Richert's powerful autocomplete)
# Sourced *before* fzf-tab
if [ -f "${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]; then
    source "${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

# 4. fzf-tab (Use fzf for tab completions)
# Sourced *after* zsh-autocomplete
if [ -f "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Optional: configure fzf-tab
    zstyle ':completion:*:*' fzf-preview 1
fi

# === fzf Keybindings (from apt package) ===
# This enables Ctrl+R history search
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
fi

# === Aliases ===
alias ll='ls -alF'
alias l='ls -CF'
alias la='ls -A'
alias gs='git status'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# === 'thefuck' Alias (Optional) ===
# Uncomment the line below if you installed 'thefuck' and want to use it.
# eval $(thefuck --alias)

```

#### `/root/.zshrc` (Root)

This file is **identical** to the user's `~/.zshrc` above.

-----

### ✅ Verification Commands

After running the script, **log out and log back in** or **reboot the VM**. Then, open a terminal:

1.  **Check Shell and Version:**

    ```bash
    echo $SHELL
    # Expected: /usr/bin/zsh
    echo $ZSH_VERSION
    # Expected: 5.9 (or similar)
    ```

2.  **Check User Plugins:**

    ```bash
    ls -l ~/.oh-my-zsh/custom/plugins
    # Expected: zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab
    ls -l ~/.zsh/zsh-autocomplete
    # Expected: Files for zsh-autocomplete
    ```

3.  **Check Root Setup:**

    ```bash
    sudo su
    ```

      * **You should see no errors.**
      * The prompt should be the Zsh (kali) theme, not a plain bash prompt.

4.  **Check Root Plugins (while root):**

    ```bash
    ls -l ~/.oh-my-zsh/custom/plugins
    # Expected: zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab
    ls -l ~/.zsh/zsh-autocomplete
    # Expected: Files for zsh-autocomplete
    exit
    ```

5.  **Test Functionality:**

      * **Syntax Highlighting:** Type `ls` (should be green), then `lskdjf` (should be red).
      * **Autosuggestions:** Type `sudo apt` and you should see a dim `install` (or similar) suggested from your history.
      * **fzf History:** Press `Ctrl+R`. A fuzzy finder menu should appear.
      * **fzf-tab:** Type `systemctl` (space) `start` (space) and press `Tab`. A fuzzy finder should appear for services.
      * **Autocomplete:** Type ` git  ` and press `Tab`. You should see rich, categorized completions.
      * **thefuck (if enabled):** Type `apt-get udpate` (typo). After it fails, type `fuck`. It should suggest `apt-get update`.

-----

### Disable Plugins (Exam Safety)

If you need to start a plain Zsh session without any plugins or configs (e.g., for an exam), run this:

```bash
zsh -f
```

This starts a "fresh" Zsh session, ignoring all `.zshrc` files. Type `exit` to return to your normal shell.

-----

### ⚠️ Troubleshooting and Rollback

#### Known Issues & Fixes

  * **Issue:** `chsh: /usr/bin/zsh is not a legal shell`

      * **Fix:** The script automatically adds Zsh to `/etc/shells`, but if it fails manually run:
        ```bash
        echo "$(which zsh)" | sudo tee -a /etc/shells
        ```

  * **Issue:** Permission errors in your home directory.

      * **Fix:** The script tries to fix this, but you can force it:
        ```bash
        sudo chown -R $USER:$USER $HOME/.oh-my-zsh $HOME/.zsh $HOME/.zshrc
        ```

  * **Issue:** Root shell is broken, but user shell is fine.

      * **Fix:** Manually copy your working user config to root:
        ```bash
        sudo cp $HOME/.zshrc /root/.zshrc
        ```

#### Safe Rollback / Uninstall

To completely undo all changes and return to Bash:

```bash
# 1. Revert default shells
sudo chsh -s /bin/bash $USER
sudo chsh -s /bin/bash root

# 2. Remove configuration files
rm -f $HOME/.zshrc $HOME/.zsh_history
sudo rm -f /root/.zshrc /root/.zsh_history

# 3. Remove plugin and cache directories
rm -rf $HOME/.oh-my-zsh $HOME/.zsh
sudo rm -rf /root/.oh-my-zsh /root/.zsh

# 4. Uninstall packages
sudo apt-get purge --auto-remove zsh zsh-autosuggestions zsh-syntax-highlighting fzf
sudo pip3 uninstall thefuck

echo "Rollback complete. Please log out and log back in."
```

-----

### 🎓 Exam Safety Note (OSCP/Proctored Exams)

  * **100% Exam-Safe:**

      * `zsh` (the shell itself)
      * `oh-my-zsh` (local framework)
      * `zsh-autosuggestions` (local scripts)
      * `zsh-syntax-highlighting` (local scripts)
      * `zsh-autocomplete` (local scripts)
      * `fzf` (local binary)
      * `fzf-tab` (local scripts)
        These tools are all **local-only**. They do not make external network calls to "phone home" or use any cloud/AI services. They are glorified text processors and are perfectly safe and permitted.

  * **Use with Caution:**

      * `thefuck`: This tool's *core logic* is local, but some of its correction rules *can* query package managers (e.g., `apt search`) to find correct package names, which involves network access. While highly unlikely to be an issue, it's not 100% "offline" in all cases. It is **not** an AI tool. For maximum exam safety, you can disable it by commenting out the `eval $(thefuck --alias)` line in your `.zshrc`.
