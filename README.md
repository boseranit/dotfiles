# dotfiles

Minimal, reproducible dotfiles. The repository currently owns the Neovim
configuration at `home/.config/nvim`; other applications can be added to the
same home mirror when they are needed.

## Install

Requirements: Git and Neovim 0.12 or newer. Tree-sitter parsers also require
`curl`, `tree-sitter-cli` 0.26.1 or newer, a C compiler (LLVM/Clang plus
Chocolatey's Strawberry Perl toolchain on Windows), ripgrep, and lazygit.
VimTeX requires a TeX distribution with `latexmk`; on Windows, SumatraPDF and
`nvr` provide PDF forward/inverse search. Mason's JavaScript and Python
language servers also require `npm`; run `:checkhealth mason` to verify its
platform tools.

Clone the repository as `dotfiles`, then run the bootstrap for your platform:

```sh
git clone https://github.com/boseranit/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
bash bootstrap.sh
```

```powershell
git clone https://github.com/boseranit/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
.\bootstrap.ps1
```

If this repository is already checked out directly at `%LOCALAPPDATA%\nvim`,
move it first so the repository and deployed configuration are separate:

```powershell
Set-Location $HOME
Move-Item "$env:LOCALAPPDATA\nvim" "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
.\bootstrap.ps1
```

The bootstrap only creates the Neovim configuration link. If a configuration
already exists, it is moved to a timestamped backup first. Plugins are then
installed automatically by lazy.nvim on the first Neovim start.

Run `:checkhealth` after installation. Useful entry points include:

- `<C-n>`: open Oil in a floating window
- `-`: open the parent directory in Oil
- `<leader>ff`, `<leader>fg`, `<leader>fb`: Telescope files, grep, buffers
- `<leader>gg`: LazyGit
- `<Tab>` / `<S-Tab>`: expand or move through snippets

Custom C++ and LaTeX snippets live in `lua/snippets`. LaTeX snippets retain
their VimTeX math-zone conditions, automatic and regex triggers, priorities,
and visual-selection behavior.
