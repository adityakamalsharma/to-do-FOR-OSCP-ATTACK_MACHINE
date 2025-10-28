This is a comprehensive, single-script solution for setting up a modern, high-performance Zsh environment on a fresh Kali Linux VM for both your normal user and the root user. It is designed to be **idempotent** (safe to re-run), **non-interactive**, and fully functional immediately upon completion.

-----

## 🚀 Zsh Power-Up Script for Kali Linux (User & Root)

This single script handles all dependencies, Oh My Zsh installation, plugin setup, permission fixes, and shell configuration for both your current user and the root user.

**Important:** You must run this script as your **normal user** (which has `sudo` privileges).

```bash
#!/bin/bash
# Zsh Power-Up Script for Kali Linux on VMware
# Sets up Zsh, Oh My Zsh, and essential plugins for both the normal user and root.
# Designed to be idempotent and non-interactive.

# --- Configuration Variables ---
USER_HOME=$(eval echo ~$USER)
ROOT_HOME="/root"

# Plugins to install (name/github_repo/clone_path)
declare -A PLUGINS=(
    ["zsh-autosuggestions"]="zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="zsh-users/zsh-syntax-highlighting"
    ["fzf-tab"]="Aloxaf/fzf-tab"
)
# Special plugin: zsh-autocomplete (cloned outside of OMZ structure)
AUTOCOMPLETE_REPO="marlonrichert/zsh-autocomplete"
USER_AUTOCOMPLETE_DIR="$USER_HOME/.zsh/zsh-autocomplete"
ROOT_AUTOCOMPLETE_DIR="$ROOT_HOME/.zsh/zsh-autocomplete"

# --- Helper Functions ---

# Function to run a command as root using sudo
run_as_root() {
    echo "  > Sudo: $1"
    sudo bash -c "$1"
    if [ $? -ne 0 ]; then
        echo "!!! Warning: Command failed: $1"
    fi
}

# Function to clone or update a git repository
clone_or_update() {
    local repo_url=$1
    local target_dir=$2
    local owner=$3 # user or root

    echo "  -> Setting up $repo_url for $owner in $target_dir..."

    if [ "$owner" == "root" ]; then
        # Run all clone/update operations as root for /root directory
        local cmd="
            if [ -d \"$target_dir/.git\" ]; then
                echo \"    - Updating existing $repo_url...\"
                cd \"$target_dir\" && git pull
            else
                echo \"    - Cloning $repo_url...\"
                mkdir -p \"$(dirname "$target_dir")\"
                git clone --depth 1 \"https://github.com/$repo_url\" \"$target_dir\"
            fi
        "
        run_as_root "$cmd"
    else
        # Run all clone/update operations as current user
        if [ -d "$target_dir/.git" ]; then
            echo "    - Updating existing $repo_url..."
            git -C "$target_dir" pull
        else
            echo "    - Cloning $repo_url..."
            mkdir -p "$(dirname "$target_dir")"
            git clone --depth 1 "https://github.com/$repo_url" "$target_dir"
        fi
    fi
}

# Function to install Oh My Zsh (if not present)
install_omz() {
    local user_type=$1 # user or root
    local target_dir=$2

    if [ ! -d "$target_dir/.oh-my-zsh" ]; then
        echo "### Installing Oh My Zsh for $user_type..."
        if [ "$user_type" == "root" ]; then
            # Run the OMZ install script as root for /root
            run_as_root "
                # Clone without running the installer script
                git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git \"$target_dir/.oh-my-zsh\"
                # Create a default zshrc so the shell starts cleanly after chsh
                if [ ! -f \"$target_dir/.zshrc\" ]; then
                    cp \"$target_dir/.oh-my-zsh/templates/zshrc.zsh-template\" \"$target_dir/.zshrc\"
                fi
                chown -R root:root \"$target_dir/.oh-my-zsh\" # Ensure correct ownership
            "
        else
            # Run OMZ install for current user
            git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$target_dir/.oh-my-zsh"
            if [ ! -f "$target_dir/.zshrc" ]; then
                cp "$target_dir/.oh-my-zsh/templates/zshrc.zsh-template" "$target_dir/.zshrc"
            fi
        fi
    else
        echo "### Oh My Zsh already exists for $user_type. Skipping install."
    fi
}

# --- Main Script Start ---
echo "=================================================="
echo " Starting Zsh Environment Setup for Kali Linux VM"
echo "=================================================="

# 1. Install Core Dependencies
echo "## 1. Installing/Updating Core Dependencies (zsh, git, curl, fzf, etc.)"
run_as_root "
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt install -y zsh git curl fzf bash-completion python3-pip
    pip3 install --upgrade thefuck
"

# 2. Install/Update Oh My Zsh
install_omz "user" "$USER_HOME"
install_omz "root" "$ROOT_HOME"

# 3. Install/Update Plugins

# --- Current User Plugins ---
echo "## 3. Setting up Plugins for Current User ($USER)"
USER_CUSTOM_DIR="$USER_HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$USER_CUSTOM_DIR"
for plugin in "${!PLUGINS[@]}"; do
    clone_or_update "${PLUGINS[$plugin]}" "$USER_CUSTOM_DIR/$plugin" "user"
done
clone_or_update "$AUTOCOMPLETE_REPO" "$USER_AUTOCOMPLETE_DIR" "user"

# --- Root User Plugins ---
echo "## 4. Setting up Plugins for Root User"
ROOT_CUSTOM_DIR="$ROOT_HOME/.oh-my-zsh/custom/plugins"
run_as_root "mkdir -p $ROOT_CUSTOM_DIR"
for plugin in "${!PLUGINS[@]}"; do
    # Cloning as root directly into /root's custom directory
    clone_or_update "${PLUGINS[$plugin]}" "$ROOT_CUSTOM_DIR/$plugin" "root"
done
clone_or_update "$AUTOCOMPLETE_REPO" "$ROOT_AUTOCOMPLETE_DIR" "root"

# Correct root ownership after cloning if necessary (ensures safety)
run_as_root "chown -R root:root $ROOT_HOME/.oh-my-zsh $ROOT_HOME/.zsh"

# 5. Write .zshrc Configuration Files

# --- User .zshrc ---
echo "## 5. Writing Zsh Configuration for User"
cat << 'EOF_USER' > "$USER_HOME/.zshrc"
# =======================================================
# Zsh Configuration for Normal User - Kali Linux VM
# =======================================================

# --- Oh My Zsh Settings ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster" # A good, simple theme with path/git status
# Core Plugins (OMZ + Custom) - Order is crucial for some features
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    # fzf-tab is loaded as a custom script later
)

source $ZSH/oh-my-zsh.sh

# --- Custom Plugin Sources and Configuration ---

# zsh-autocomplete (Cloned outside of OMZ structure)
AUTOCOMPLETE_DIR="$HOME/.zsh/zsh-autocomplete"
if [ -f "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh" ]; then
    source "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh"
fi

# fzf-tab (Loaded as a custom plugin)
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Basic FZF-Tab Configuration
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range :50 {}' 2>/dev/null || \
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'head -50 {}'
fi

# --- FZF Keybindings and Configuration ---
# Uses the built-in fzf key-bindings from the package install
# CTRL-R (history search) should now show a fuzzy list.
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'

# --- The Fuck (Python tool for correcting commands) ---
eval $(thefuck --alias)

# --- History Tweak ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- Helpful Aliases ---
alias update='sudo apt update && sudo apt upgrade -y'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias gs='git status'
alias gcl='git clone'
alias tf='thefuck'
alias kali-ip='ip a | grep "inet " | grep -v 127.0.0.1'

# --- Kali/VMware Specific Tweaks (Optional) ---
# Prevents some terminal size/drawing issues in VMs
# if [ -n "$KALI_VMWARE" ]; then # Not perfect for detection, but safe to include.
#     export TERM="xterm-256color"
# fi

# --- Final Message ---
echo "Welcome to Zsh! Type 'tf' after an error to fix it."
# =======================================================
EOF_USER

# --- Root .zshrc ---
echo "## 6. Writing Zsh Configuration for Root"
ROOT_ZSHRC_CONTENT=$(cat << EOF_ROOT
# =======================================================
# Zsh Configuration for Root User - Kali Linux VM
# =======================================================

# --- Oh My Zsh Settings ---
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="robbyrussell" # Simpler theme for root for less visual clutter
# Core Plugins (OMZ + Custom) - Order is crucial for some features
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source \$ZSH/oh-my-zsh.sh

# --- Custom Plugin Sources and Configuration ---

# zsh-autocomplete (Cloned outside of OMZ structure)
AUTOCOMPLETE_DIR="/root/.zsh/zsh-autocomplete"
if [ -f "\$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh" ]; then
    source "\$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh"
fi

# fzf-tab (Loaded as a custom plugin)
if [ -f "\${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "\${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Basic FZF-Tab Configuration (no 'bat' for root safety/simplicity)
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'head -50 {}'
fi

# --- FZF Keybindings and Configuration ---
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'

# --- The Fuck (Python tool for correcting commands) ---
eval \$(thefuck --alias)

# --- History Tweak ---
HISTFILE=/root/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- Helpful Aliases ---
alias update='apt update && apt upgrade -y'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias gs='git status'
alias gcl='git clone'
alias tf='thefuck'
alias kali-ip='ip a | grep "inet " | grep -v 127.0.0.1'

# --- Final Message ---
echo "Root Zsh ready."
# =======================================================
EOF_ROOT
# Write the content to /root/.zshrc as root
run_as_root "echo \"$ROOT_ZSHRC_CONTENT\" > \"$ROOT_HOME/.zshrc\""
# Ensure correct ownership and permissions
run_as_root "chown root:root $ROOT_HOME/.zshrc"

# 7. Change Default Shell
echo "## 7. Changing Default Shells to Zsh"
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "  -> Changing default shell for $USER to /usr/bin/zsh"
    chsh -s /usr/bin/zsh
fi
run_as_root "
    if [ \"$(getent passwd root | cut -d: -f7)\" != \"/usr/bin/zsh\" ]; then
        echo \"  -> Changing default shell for root to /usr/bin/zsh\"
        chsh -s /usr/bin/zsh root
    fi
"

# 8. Final Summary
echo "=================================================="
echo " ✅ Setup Complete! Please **RESTART YOUR TERMINAL** or run 'zsh' now."
echo " The next time you log in or open a terminal, Zsh will be your shell."
echo " To test the root shell, run: **sudo su -**"
echo "=================================================="
```

-----

## 📄 Final `.zshrc` Configurations

### 1\. Normal User (`~/.zshrc`)

```bash
# =======================================================
# Zsh Configuration for Normal User - Kali Linux VM
# =======================================================

# --- Oh My Zsh Settings ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster" # A good, simple theme with path/git status
# Core Plugins (OMZ + Custom) - Order is crucial for some features
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    # fzf-tab is loaded as a custom script later
)

source $ZSH/oh-my-zsh.sh

# --- Custom Plugin Sources and Configuration ---

# zsh-autocomplete (Cloned outside of OMZ structure)
AUTOCOMPLETE_DIR="$HOME/.zsh/zsh-autocomplete"
if [ -f "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh" ]; then
    source "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh"
fi

# fzf-tab (Loaded as a custom plugin)
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Basic FZF-Tab Configuration
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range :50 {}' 2>/dev/null || \
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'head -50 {}'
fi

# --- FZF Keybindings and Configuration ---
# Uses the built-in fzf key-bindings from the package install
# CTRL-R (history search) should now show a fuzzy list.
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'

# --- The Fuck (Python tool for correcting commands) ---
eval $(thefuck --alias)

# --- History Tweak ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- Helpful Aliases ---
alias update='sudo apt update && sudo apt upgrade -y'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias gs='git status'
alias gcl='git clone'
alias tf='thefuck'
alias kali-ip='ip a | grep "inet " | grep -v 127.0.0.1'

# --- Kali/VMware Specific Tweaks (Optional) ---
# Prevents some terminal size/drawing issues in VMs
# if [ -n "$KALI_VMWARE" ]; then # Not perfect for detection, but safe to include.
#     export TERM="xterm-256color"
# fi

# --- Final Message ---
echo "Welcome to Zsh! Type 'tf' after an error to fix it."
# =======================================================
```

### 2\. Root User (`/root/.zshrc`)

```bash
# =======================================================
# Zsh Configuration for Root User - Kali Linux VM
# =======================================================

# --- Oh My Zsh Settings ---
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="robbyrussell" # Simpler theme for root for less visual clutter
# Core Plugins (OMZ + Custom) - Order is crucial for some features
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Custom Plugin Sources and Configuration ---

# zsh-autocomplete (Cloned outside of OMZ structure)
AUTOCOMPLETE_DIR="/root/.zsh/zsh-autocomplete"
if [ -f "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh" ]; then
    source "$AUTOCOMPLETE_DIR/zsh-autocomplete.plugin.zsh"
fi

# fzf-tab (Loaded as a custom plugin)
if [ -f "${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
    # Basic FZF-Tab Configuration (no 'bat' for root safety/simplicity)
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'head -50 {}'
fi

# --- FZF Keybindings and Configuration ---
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'

# --- The Fuck (Python tool for correcting commands) ---
eval $(thefuck --alias)

# --- History Tweak ---
HISTFILE=/root/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- Helpful Aliases ---
alias update='apt update && apt upgrade -y'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias gs='git status'
alias gcl='git clone'
alias tf='thefuck'
alias kali-ip='ip a | grep "inet " | grep -v 127.0.0.1'

# --- Final Message ---
echo "Root Zsh ready."
# =======================================================
```

-----

## ✅ Verification Commands

After **restarting your terminal** (or running `zsh`), run these commands to verify the setup:

```bash
# 1. Check current shell (should show /usr/bin/zsh)
echo $SHELL
# 2. Check root shell (should show /usr/bin/zsh)
sudo su - -c 'echo $SHELL'
# 3. Check for plugins (all should return '0' for success)
type _zsh_autosuggestions_start
type zsh-syntax-highlighting
type zsh-autocomplete
# 4. Test functionality in the current shell:
#   - Type 'echo' then press **Tab** (should show fzf-tab fuzzy completion list).
#   - Start typing 'ls /u' (should see inline suggestion from autosuggestions).
#   - Type 'ech' (should see autocomplete suggestions for 'echo' and 'ECHO').
#   - Type 'lssss' and press **Enter**, then type **tf** and press **Enter** (should correct the command).
# 5. Test functionality for root:
#   - Run 'sudo su -' and repeat the tests above. No errors should appear on login.
```

-----

## 🚫 Quick-Disable One-Liner (Exam Safety)

To immediately start a **plain Zsh session** without sourcing the **plugins or Oh My Zsh**, which is useful for exam environments (OSCP/OSCE), run this:

```bash
zsh -f
```

-----

## 🔧 Troubleshooting and Rollback

### 🚨 Known Issues and Fixes

| Issue | Description | Exact Fix Command(s) |
| :--- | :--- | :--- |
| **`sudo su` errors** | Errors like `/root/.oh-my-zsh/oh-my-zsh.sh not found` appear when switching to root. | Rerun the setup script, which ensures OMZ is installed for root and the **`/root/.zshrc`** points to the correct location. |
| **Plugin Permissions** | Plugins in `/root/.oh-my-zsh/custom` are owned by the normal user. | `sudo chown -R root:root /root/.oh-my-zsh /root/.zsh` (The script does this automatically, but you can run it manually if needed). |
| **FZF Keybinding** | `Ctrl+R` history search is not working properly (not launching FZF). | Ensure the `fzf` package is installed: `sudo apt install -y fzf`. The script handles this, but a re-install might fix a corrupt install. |
| **`/root` config errors** | When switching to root, the new shell doesn't pick up Zsh. | Check that the root shell is set: `sudo chsh -s /usr/bin/zsh root`. |

### 🔙 Safe Rollback/Uninstall

Use these commands to fully revert the changes and restore **Bash** as your shell.

```bash
#!/bin/bash
echo "--- Starting Zsh Uninstall and Bash Restore ---"

# 1. Restore Shells to Bash
echo "Restoring default shell to /bin/bash for user and root..."
chsh -s /bin/bash
sudo chsh -s /bin/bash root

# 2. Remove Config Files (Optional - consider backing up first!)
echo "Removing Zsh configuration files (USER and ROOT)..."
rm -f ~/.zshrc ~/.zsh_history
sudo rm -f /root/.zshrc /root/.zsh_history

# 3. Remove Oh My Zsh and Plugin Directories
echo "Removing Oh My Zsh and custom plugin directories..."
rm -rf ~/.oh-my-zsh ~/.zsh
sudo rm -rf /root/.oh-my-zsh /root/.zsh

# 4. Clean up thefuck (Optional)
# echo "Removing thefuck..."
# sudo pip3 uninstall -y thefuck

echo "--- Rollback Complete. Please RESTART YOUR TERMINAL. ---"
echo "Your shell is now set back to /bin/bash."
```

-----

## 🛡️ Exam Safety Note (OSCP/Similar)

| Component | Installation/Setup | Exam Safety (Local vs. External) |
| :--- | :--- | :--- |
| **Zsh, git, fzf** | Installed from Kali's local APT repositories. | **SAFE** (Local tool) |
| **`oh-my-zsh`** | Cloned from GitHub during setup. | **SAFE** (Local tool, uses no external services after installation) |
| **Plugins** | Cloned from GitHub during setup. | **SAFE** (Local tool, uses no external services after installation) |
| **`thefuck`** | Installed via `pip` (requires external PyPI access). | **NOT SAFE** (Requires external network access during exam, **Do NOT use during exam**) |
| **All Aliases/Configs** | Configuration is **local-only**. | **SAFE** (Local files) |

**Conclusion:** The core Zsh environment, including OMZ and all plugins, is **SAFE** for use in certification exams as it only relies on local scripts and binaries after the initial setup. **`thefuck`** is the only external service/tool that should be avoided or disabled during the exam itself, though the configuration allows it to be installed now. You can comment out the `eval $(thefuck --alias)` line in your `.zshrc` files for exam integrity.
