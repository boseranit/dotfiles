# Managed by the dotfiles repository.
case $- in
  *i*) ;;
  *) return ;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s checkwinsize histappend

[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.pixi/bin" ]] && PATH="$HOME/.pixi/bin:$PATH"
export PATH

[[ -r "$HOME/.config/shell/aliases.sh" ]] &&
  source "$HOME/.config/shell/aliases.sh"
[[ -r "$HOME/.config/dotfiles/machine/shell.sh" ]] &&
  source "$HOME/.config/dotfiles/machine/shell.sh"
[[ -r "$HOME/.config/dotfiles/local/shell.sh" ]] &&
  source "$HOME/.config/dotfiles/local/shell.sh"

if [[ -x /usr/bin/dircolors ]]; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

if ! shopt -oq posix; then
  [[ -r /usr/share/bash-completion/bash_completion ]] &&
    source /usr/share/bash-completion/bash_completion
fi
