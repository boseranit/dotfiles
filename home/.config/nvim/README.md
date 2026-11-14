# Neovim configuration

This configuration targets Neovim 0.12 or newer and is installed by the root
bootstrap script. Plugins are pinned by `lazy-lock.json` and bootstrapped by
lazy.nvim on first launch.

## Runtime dependencies

- Git for plugin installation
- A C/C++ toolchain and Tree-sitter CLI 0.26.1 or newer (not installed via npm) for parser builds
- ripgrep and fd for Telescope
- lazygit for the Git UI
- `latex2text` for render-markdown formulas
- Node.js/npm, BasedPyright, and Ruff for language tooling
- `latexmk` and a PDF viewer only when using VimTeX

On Debian, the compiler and Git come from `packages/system/debian.txt`; the
portable CLI tools, Node.js, BasedPyright, and Ruff come from the Pixi global
manifest. Mason manages Clangd and Lua Language Server, appending its binaries
to PATH so Pixi remains authoritative for Python tooling.

The canonical `nvim-treesitter` main branch includes its parser registry; no
separate registry plugin is needed. Run `:TSUpdate` after plugin upgrades to
keep installed parsers compatible with the queries.

When upgrading from the `neovim-treesitter` fork, reinstall existing parsers
once to replace its incompatible query layout and revision metadata:

```vim
:lua local ts = require("nvim-treesitter"); local languages = ts.get_installed(); ts.uninstall(languages):wait(300000); ts.install(languages):wait(300000)
```

Smart-splits v3 uses the separate `smart-splits-nvim/backend-tmux` plugin for
tmux/psmux integration. Its `mux.backend` is configured explicitly; outside
tmux, navigation and resizing still work between Neovim windows. The tmux
configuration owns the corresponding Ctrl/Alt-h/j/k/l bindings.

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

See [CHEATSHEET.md](CHEATSHEET.md) for mappings and everyday editor behavior.

## Machine-local settings

Tracked machine differences belong in the selected profile's `nvim.lua`.
Private settings belong in `~/.config/dotfiles/local/nvim.lua`, outside the
repository. For example, either file can disable VimTeX and its custom TeX
snippets with:

```lua
vim.g.dotfiles_latex = false
```
