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

autoload -Uz compinit && compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# TODO: figure out what is goign on here?
autoload -U colors && colors
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' auto-description 'specify: %d' zstyle ':completion:*' use-cache on zstyle ':completion:*' cache-path ~/.zsh/cache
_comp_options+=(globdots)
zmodload zsh/complist
compdef eza=ls




alias ls='eza --icons'
alias ll='eza -lha --icons --git'
alias v=nvim
alias vi=nvim
alias ta="tmux-attach -t 0 || tmux"
alias zrc='nvim "$ZDOTDIR"/.zshrc && source "$ZDOTDIR"/.zshrc'
alias vrc="nvim ~/.config/nvim/init.lua"
alias e=exit
alias o=open
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
  # Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
  bindkey '^[[1;5C' forward-word

  # Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
  bindkey '^\' autosuggest-toggle

  # Up/Down -> history search by substring (^[[A/^[[B are up/down arrow escape codes)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

   # fzf (brew version)
  [ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  [ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

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

