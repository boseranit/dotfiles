#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
stamp="$(date +%Y%m%d%H%M%S)"
dry_run=false
machine=

: "${HOME:?HOME must be set}"

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      dry_run=true
      shift
      ;;
    --machine)
      if [[ $# -lt 2 ]]; then
        printf '%s\n' '--machine requires a profile name.' >&2
        exit 2
      fi
      machine=$2
      shift 2
      ;;
    *)
      printf 'Usage: %s [--dry-run] [--machine NAME]\n' "$0" >&2
      exit 2
      ;;
  esac
done

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
  local source=$1
  local target=$2

  if [[ ! -e "$source" ]]; then
    printf 'Missing source: %s\n' "$source" >&2
    exit 1
  fi

  local source_path target_path
  source_path="$(readlink -f -- "$source")"
  if [[ -e "$target" || -L "$target" ]]; then
    target_path="$(cd -- "$(dirname -- "$target")" && pwd -P)/$(basename -- "$target")"
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

machine_link="$HOME/.config/dotfiles/machine"
if [[ -z "$machine" && -L "$machine_link" ]]; then
  machine="$(basename -- "$(readlink -- "$machine_link")")"
fi

if [[ ! "$machine" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  printf 'Select a machine profile with --machine NAME.\n' >&2
  exit 2
fi

machine_source="$repo/machines/$machine"
if [[ ! -d "$machine_source" ]]; then
  printf 'Unknown machine profile: %s\n' "$machine" >&2
  exit 2
fi

link_path "$machine_source" "$machine_link"

local_config="$HOME/.config/dotfiles/local"
if $dry_run; then
  printf 'Would ensure private configuration directory %s\n' "$local_config"
else
  mkdir -p -- "$local_config"
  chmod 700 -- "$local_config"
fi

for path in .bashrc .gitconfig .config/shell .config/tmux \
  .pixi/manifests/pixi-global.toml; do
  link_path "$repo/home/$path" "$HOME/$path"
done

# Neovim follows XDG_CONFIG_HOME on Unix; the other files mirror $HOME.
link_path "$repo/home/.config/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

printf '\nConfiguration deployed for machine profile %s. Package installation remains explicit:\n' "$machine"
printf '  pixi global sync\n'
printf '  nvim --headless '\''+Lazy! sync'\'' +qa\n'
