export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export EDITOR=nvim
export VISUAL=nvim

if command -v xclip &> /dev/null; then
  alias pbcopy="xclip -selection clipboard"
  alias pbpaste="xclip -selection clipboard -o"
elif command -v wl-copy &> /dev/null; then
  alias pbcopy="wl-copy"
  alias pbpaste="wl-paste"
fi

# Function to copy the output of the previous command directly
copy-last-output() {
  # Check if there is a saved output from the last command
  local output=$(fc -ln -1 | sh 2>&1)
  echo "$output" | pbcopy
  echo "Last command output copied to clipboard!"
}
bindkey -s '^y' 'copy-last-output\n'

# Add vim mode
bindkey -v

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias av="source .venv/bin/activate"
alias vim='nvim'
alias vi='nvim'

# Node:
export NODE_OPTIONS=--no-network-family-autoselection
export NVM_DIR="$HOME/.nvm"

# Fast startup: put the current default Node on PATH, but only load nvm itself
# when the `nvm` command is used.
_node_bin="$NVM_DIR/versions/node/v24.9.0/bin"
if [[ -d "$_node_bin" && ":$PATH:" != *":$_node_bin:"* ]]; then
  path=("$_node_bin" $path)
fi
unset _node_bin

_load_nvm() {
  unfunction nvm 2>/dev/null || true
  [[ -s /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
  [[ -s /usr/share/nvm/bash_completion ]] && source /usr/share/nvm/bash_completion
}

nvm() {
  _load_nvm
  nvm "$@"
}

# Use Starship as the prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# Alias for eza
alias ls='eza --color=auto'
alias ll='eza --color=auto -l'
alias la='eza --color=auto -la'


# Alias for git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gm='git merge'
alias gr='git rebase'
alias gl='git log --oneline --graph --decorate --color=always'
alias gst='git stash'
alias gapply='git stash apply'
alias gd='git diff'
alias gt='git tag'
alias gf='git fetch'
alias grs='git reset'
alias gshow='git show'

# Lazy-load thefuck; generating the alias starts Python and is expensive.
fuck() {
  unfunction fuck 2>/dev/null || true
  eval "$(thefuck --alias)"
  fuck "$@"
}
alias fu="fuck"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
zinit light zsh-users/zsh-autosuggestions
bindkey '^l' autosuggest-accept
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# Keep pi-memory qmd indexing manual; automatic background embeds can spawn
# multiple CPU-heavy `qmd embed` processes across concurrent pi sessions.
export PI_MEMORY_QMD_UPDATE=manual

# Run pi with a tmux-split external editor without affecting other programs.
pi() {
  if ! command -v pi >/dev/null 2>&1; then
    _load_nvm
  fi
  VISUAL="$HOME/bin/pi-tmux-editor" EDITOR="$HOME/bin/pi-tmux-editor" command pi "$@"
}


# bun completions
[ -s "/home/danielh/.bun/_bun" ] && source "/home/danielh/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
