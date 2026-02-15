export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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
		# Strip ANSI color codes from $cwd just in case
		clean_cwd="$(printf '%s' "$cwd" | sed -E 's/\x1b\[[0-9;]*m//g')"
		cd -- "$clean_cwd"
	fi
	rm -f -- "$tmp"
}

alias av="source .venv/bin/activate"
alias vim='nvim'
alias vi='nvim'

# Node:
source /usr/share/nvm/init-nvm.sh
source /usr/share/nvm/bash_completion

# Use Starship as the prompt
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
type starship_zle-keymap-select >/dev/null || \
  {
    echo "Load starship"
    eval "$(starship init zsh)"
  }

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# Alias for eza
alias ls='eza --color=auto'
alias ll='eza --color=auto -l'
alias la='eza --color=auto -la'

# Alias for bat
alias cat='bat --paging=always --style=plain --color=always'

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

eval "$(thefuck --alias)"
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

