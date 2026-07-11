#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source="$repo/home/.config/nvim"
target="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [[ ! -d "$source" ]]; then
  printf 'Missing Neovim configuration: %s\n' "$source" >&2
  exit 1
fi

case "$source/" in
  "$target/"*)
    printf 'Move this repository outside %s before running bootstrap.\n' "$target" >&2
    exit 1
    ;;
esac

if [[ -L "$target" ]]; then
  link="$(readlink "$target")"
  case "$link" in
    /*) ;;
    *) link="$(dirname "$target")/$link" ;;
  esac

  if [[ -d "$link" ]] && [[ "$(cd "$link" && pwd -P)" == "$(cd "$source" && pwd -P)" ]]; then
    printf '%s is already linked\n' "$target"
    exit 0
  fi
fi

mkdir -p "$(dirname "$target")"
if [[ -e "$target" || -L "$target" ]]; then
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  suffix=0
  while [[ -e "$backup" || -L "$backup" ]]; do
    suffix=$((suffix + 1))
    backup="$target.backup.$(date +%Y%m%d%H%M%S).$suffix"
  done
  mv "$target" "$backup"
  printf 'Backed up %s to %s\n' "$target" "$backup"
fi

ln -s "$source" "$target"
printf 'Linked %s -> %s\n' "$target" "$source"
