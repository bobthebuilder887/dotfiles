export IPYTHONDIR="$HOME/.config/ipython"
export EDITOR="nvim"
export GIT_EDITOR="$EDITOR"
export VISUAL="nvim"
export TERMINAL="ghostty"
export BROWSER="open"
export LESS="-R"
export LESSHISTFILE=-
export MANPAGER="bat -l man -p"
export BAT_THEME="ansi"
export BAT_PAGER="less -FR"
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_EDITOR="$EDITOR"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Work-related configuration
[[ -f $ZDOTDIR/work.zsh ]] && source $ZDOTDIR/work.zsh

SHELL_SESSION_DIR="$XDG_STATE_HOME/zsh/sessions"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

# Shared history between active session without space and duplicates
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_FCNTL_LOCK
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# Load the zsh completion system
autoload -Uz compinit
# Required for menu selection and colored completion lists
zmodload zsh/complist
# Generate/load completion cache for faster startup
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
# Interactive completion menu (arrow keys, tab navigation)
zstyle ':completion:*' menu select
# Group results by category (files, dirs, commands, etc.)
zstyle ':completion:*' group-name ''
# Show descriptions next to completion entries
zstyle ':completion:*' verbose yes
# Description format for completion groups
zstyle ':completion:*' auto-description 'specify: %d'
# Case-insensitive + substring matching
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|=*' \
  'l:|=* r:|=*'

# Use LS_COLORS for colored completion listings if available
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Cache expensive completion results (e.g. package managers)
zstyle ':completion:*' use-cache on
# Location for completion caches
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh"
# Include hidden files in completion results
_comp_options+=(globdots)
# Reuse ls completions for eza
compdef eza=ls

alias ls='eza --icons'
alias ll='eza -lha --icons --git'
alias v=nvim
alias vim=nvim
alias ta="tmux attach-session -t 0 || tmux"
alias zrc='nvim "$ZDOTDIR"/.zshrc && source "$ZDOTDIR"/.zshrc'
alias vrc="nvim ~/.config/nvim/init.lua"
alias e=exit
alias o=open
alias b=btop
alias a='source ./.venv/bin/activate'
alias d=deactivate
alias py='./.venv/bin/ipython'
alias ipython='./.venv/bin/ipython'

source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/fzf.zsh

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
  bindkey '^P' autosuggest-accept

  # Ctrl-J / Ctrl-K navigate substring history
  bindkey '^J' history-substring-search-down
  bindkey '^K' history-substring-search-up

  # Keep arrows as fallback for history search
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  # Ctrl-Right / Ctrl-Left move by word
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

   # fzf (brew version)
  [ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ] && source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
  [ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ] && source "/opt/homebrew/opt/fzf/shell/completion.zsh"

  # Binding for lazygit
  function open_lazygit() {
    zle -I            # clear prompt
    lazygit
    zle redisplay     # restore prompt after exit
  }
  zle -N open_lazygit
  bindkey '^g' open_lazygit
  
  # Navigating directories
  bindkey -s '^u' 'cd ..^M'  # Go one directory above
  bindkey -s '^h' 'cd ~^M'   # Go-to home directory
  bindkey -s '^y' 'cd -^M'   # Go-to Previous directory
  # Go to any directory in home
  bindkey -s '^O' 'cd "$(fd . ~ --type d | fzf --preview-window=right:50% --preview "tree -C -L 1 -a --dirsfirst {}")"^M'
}
