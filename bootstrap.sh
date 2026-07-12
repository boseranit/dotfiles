#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
stamp="$(date +%Y%m%d%H%M%S)"
dry_run=false

: "${HOME:?HOME must be set}"

if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
elif [[ $# -gt 0 ]]; then
  printf 'Usage: %s [--dry-run]\n' "$0" >&2
  exit 2
fi

backup_target() {
  local target=$1
  local backup="${target}.backup.${stamp}"
  local suffix=0

  while [[ -e "$backup" || -L "$backup" ]]; do
    suffix=$((suffix + 1))
    backup="${target}.backup.${stamp}.${suffix}"
  done

  if $dry_run; then
    printf 'Would back up %s to %s\n' "$target" "$backup"
  else
    mv -- "$target" "$backup"
    printf 'Backed up %s to %s\n' "$target" "$backup"
  fi
}

link_path() {
  local relative=$1
  local source="$repo/home/$relative"
  local target=${2:-"$HOME/$relative"}

  if [[ ! -e "$source" ]]; then
    printf 'Missing source: %s\n' "$source" >&2
    exit 1
  fi

  local source_path target_path target_parent
  source_path="$(readlink -f -- "$source")"
  target_parent="$(readlink -m -- "$(dirname -- "$target")")"
  target_path="$target_parent/$(basename -- "$target")"
  if [[ "$source_path" == "$target_path" || "$source_path" == "$target_path/"* ]]; then
    printf 'Source %s is inside managed target %s; move the repository first.\n' \
      "$source" "$target" >&2
    exit 1
  fi

  if [[ -L "$target" ]] &&
    [[ "$(readlink -f -- "$target")" == "$source_path" ]]; then
    printf 'Already linked %s\n' "$target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_target "$target"
  fi

  if $dry_run; then
    printf 'Would link %s -> %s\n' "$target" "$source"
  else
    mkdir -p -- "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source"
  fi
}

managed_paths=(
  ".bashrc"
  ".gitconfig"
  ".config/shell"
  ".config/tmux"
  ".pixi/manifests/pixi-global.toml"
)

for path in "${managed_paths[@]}"; do
  link_path "$path"
done

# Neovim follows XDG_CONFIG_HOME on Unix; the other files mirror $HOME.
link_path ".config/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

printf '\nConfiguration deployed. Package installation remains explicit:\n'
printf '  pixi global sync\n'
printf '  nvim --headless '\''+Lazy! sync'\'' +qa\n'
