#!/usr/bin/env bash
set -euo pipefail

viewer=${SUMATRAPDF:-SumatraPDF.exe}
pdf_path=
viewer_args=()

for arg in "$@"; do
  if [[ "$arg" == /* ]]; then
    [[ "$arg" == *.pdf ]] && pdf_path=$arg
    viewer_args+=("$(wslpath -m -- "$arg")")
  else
    viewer_args+=("$arg")
  fi
done

# SumatraPDF also reads source paths from the SyncTeX archive. Convert those
# paths so forward search agrees with the Windows-style command arguments.
if [[ -n "$pdf_path" ]]; then
  synctex_path="${pdf_path%.pdf}.synctex.gz"
  if [[ -f "$synctex_path" ]]; then
    temp_path=$(mktemp "${synctex_path}.XXXXXX")
    if gzip -cd -- "$synctex_path" |
      while IFS= read -r line; do
        if [[ "$line" =~ ^(Input:[0-9]+:)(/[^/].*)$ ]]; then
          printf '%s%s\n' "${BASH_REMATCH[1]}" "$(wslpath -m -- "${BASH_REMATCH[2]}")"
        else
          printf '%s\n' "$line"
        fi
      done |
      gzip >"$temp_path"; then
      mv -- "$temp_path" "$synctex_path"
    else
      rm -f -- "$temp_path"
      exit 1
    fi
  fi
fi

exec "$viewer" "${viewer_args[@]}"
