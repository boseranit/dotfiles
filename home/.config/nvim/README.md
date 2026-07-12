# Neovim configuration

This configuration targets Neovim 0.12 or newer and is installed by the root
bootstrap script. Plugins are pinned by `lazy-lock.json` and bootstrapped by
lazy.nvim on first launch.

## Runtime dependencies

- Git for plugin installation
- A C/C++ toolchain and Tree-sitter CLI for parser builds
- ripgrep and fd for Telescope
- lazygit for the Git UI
- Node.js/npm for Mason's Pyright package
- `latexmk` and a PDF viewer only when using VimTeX

On Debian, the compiler and Git come from `packages/system/debian.txt`; the
portable CLI tools and Node.js come from the Pixi global manifest.

On WSL, VimTeX opens PDFs with the Windows SumatraPDF installation. The
tracked adapter under `scripts/` converts command and SyncTeX paths to Windows
format, so no Linux PDF viewer is required.

On native Windows, install LLVM and Strawberry Perl in their default
locations. The configuration uses Clang with Strawberry's MinGW libraries when
`CC` is not already set; this avoids `tree-sitter-cli` selecting a missing
`cl.exe`. Mason also requires 7-Zip. The PowerShell bootstrap and
`pixi global sync` must run before the first editor launch.

Run these checks after deployment:

```sh
nvim --headless '+Lazy! sync' +qa
nvim --headless '+checkhealth' '+w! /tmp/nvim-health.txt' +qa
```

The second command is for Linux. On Windows, run `:checkhealth` interactively.

Useful mappings include:

- `<C-n>`: open Oil in a floating window
- `-`: open the parent directory in Oil
- `<leader>ff`, `<leader>fg`, `<leader>fb`: Telescope files, grep, buffers
- `<leader>gg`: LazyGit
- `<Tab>` / `<S-Tab>`: expand or move through snippets

Custom C++ and LaTeX snippets live under `lua/snippets`.

The clipboard provider is selected at runtime: tmux inside tmux, OSC 52 for a
direct display-less SSH session, and the native provider otherwise. With
`unnamedplus`, ordinary yanks copy through the selected provider.

## Machine-local settings

Tracked machine differences belong in the selected profile's `nvim.lua`.
Private settings belong in `~/.config/dotfiles/local/nvim.lua`, outside the
repository. For example, either file can disable VimTeX and its custom TeX
snippets with:

```lua
vim.g.dotfiles_latex = false
```
