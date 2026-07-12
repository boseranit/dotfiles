# WSL Debian

Primary development environment: Debian 13 (Trixie) on WSL2, x86-64.

## Shared state used

- All tracked files under `home/`
- `packages/system/debian.txt`
- All environments in the Pixi global manifest
- Standalone Pixi, Neovim, Codex, and RTK

## Machine-specific notes

- Linux Neovim is independent of the Windows Neovim installation.
- `xclip` provides the clipboard provider when an X/WSLg clipboard is
  available. Verify with `:checkhealth provider`.
- VimTeX uses Debian's `latexmk` and opens PDFs with the Windows SumatraPDF
  installation through the tracked WSL path adapter.
- Git identity belongs in `~/.gitconfig.local` and is never committed.
- WSL-only paths, secrets, and service configuration stay outside this repo.
