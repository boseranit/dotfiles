# WSL Debian

Debian 13 (Trixie) on WSL2, x86-64. Select with:

```sh
./bootstrap.sh --machine wsl-debian
```

## Differences from the shared base

- `xclip` integrates with the X/WSLg clipboard provider.
- VimTeX uses Debian's `latexmk` and opens PDFs with Windows SumatraPDF through
  the shared WSL adapter.
- Linux Neovim remains independent of the Windows installation.

WSL-only paths, secrets, and service configuration remain private
configuration.
