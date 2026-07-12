# Shared interactive-shell aliases. Machine-only aliases belong in local.sh.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias gs='git status'
alias gcm='git commit -m'
alias ga='git add -u'
alias gds='git diff --numstat'
alias gd='git diff'
alias gmain='git switch main && git pull'

if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
fi
