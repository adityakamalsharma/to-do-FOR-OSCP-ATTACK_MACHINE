
# === Zsh Configuration: Portable for User & Root ===
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
ZDOTDIR=${ZDOTDIR:-$HOME}

# Theme and general settings
ZSH_THEME="robbyrussell"
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
alias ll='ls -alF'
alias l='ls -CF'
alias la='ls -A'
alias gs='git status'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

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
    zstyle ':completion:*:*' fzf-preview 1
fi

# --- fzf Keybindings (Ctrl+R History Search) ---
if [ -f /usr/share/fzf/key-bindings.zsh ];
then
    source /usr/share/fzf/key-bindings.zsh
fi


# TheFuck activation (type 'fuck' after a mistyped command)
eval $(thefuck --alias)

# ---------------------------------------------
# Zsh History Configuration for Portability
# ---------------------------------------------
# Ensures history file is explicitly defined and loads/saves reliably.
# The content of ~/.zsh_history can be copied to a new system for instant command history recall.

# Explicitly set the history file path (Note: $HOME is escaped to be interpreted by Zsh later)
HISTFILE="$HOME/.zsh_history"

# Set the maximum number of history entries to keep in memory and on disk
HISTSIZE=10000
SAVEHIST=10000

# Options for history management:
setopt appendhistory      # Append history to the history file (don't overwrite)
setopt extendedhistory    # Save timestamps and command duration
setopt hist_expiredups_first # Delete older duplicates first
setopt hist_ignore_dups   # Don't record consecutive identical commands
setopt hist_ignore_space  # Don't record commands starting with a space
setopt sharehistory       # Share history among all open shells


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"
