export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
# Use Starship as the prompt
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

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


alias python='uv run python'

eval "$(thefuck --alias)"
alias fu="fuck"
# alias zshconfig="mate ~/.zshrc"

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
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# eval "$(_MARIMO_COMPLETE=zsh_source marimo)"
