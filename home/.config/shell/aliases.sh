# Shared interactive-shell aliases. Machine-only aliases belong in local.sh.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
fi
