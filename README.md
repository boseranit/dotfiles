# dotfiles

Minimal, reproducible configuration for Debian, WSL Debian, and Windows where
the same configuration is useful. The repository records desired state; it
does not try to turn every application into a bespoke installer.

## Sources of truth

| Concern | Source of truth |
| --- | --- |
| Shell, Neovim, tmux, and Git configuration | `home/` |
| Portable CLI tools such as Zig and jq | `home/.pixi/manifests/pixi-global.toml` |
| Essential OS packages | `packages/system/<distribution>.txt` |
| Upstream standalone installers | `packages/standalone.md` |
| Per-machine choices and exceptions | `machines/<machine>.md` |
| Services such as Immich and Seafile | A separate `homelab` repository |
| Secrets, data, caches, and installed binaries | Outside Git |

`home/` mirrors paths below `$HOME`. Bootstrap links only the files and
application directories owned by this repository, backing up conflicts first.
It deliberately does not install packages or services.

## Debian / WSL Debian setup

Install the small OS-level base:

```sh
sudo apt-get update
grep -Ev '^\s*(#|$)' packages/system/debian.txt |
  xargs sudo apt-get install -y
```

Install the standalone tools listed in [packages/standalone.md](packages/standalone.md),
including Pixi and Neovim, then deploy the configuration:

```sh
./bootstrap.sh
pixi global sync
nvim --headless '+Lazy! sync' +qa
```

Git identity is intentionally machine-local. Create `~/.gitconfig.local` after
bootstrapping:

```ini
[user]
    name = Your Name
    email = you@example.com
```

See [machines/wsl-debian.md](machines/wsl-debian.md) for this machine and
[home/.config/nvim/README.md](home/.config/nvim/README.md) for editor details.

## Windows setup

Install Git, Pixi, and the pinned Neovim release recorded in
[packages/standalone.md](packages/standalone.md). Native Tree-sitter parser
builds also need LLVM Clang and Strawberry Perl in their default locations;
Mason needs 7-Zip. Then clone the repository on the same drive as `$HOME` and
run from PowerShell:

```powershell
git clone https://github.com/boseranit/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
.\bootstrap.ps1
pixi global sync
nvim --headless "+Lazy! sync" +qa
```

The PowerShell bootstrap maps Neovim to `%LOCALAPPDATA%\nvim` and deploys the
portable home files that are meaningful on Windows. Existing targets receive a
timestamped backup. It uses a directory junction for Neovim and hard links for
individual files, so it does not require elevation or Developer Mode.

## Repository layout

```text
.
├── bootstrap.sh
├── bootstrap.ps1
├── home/
│   ├── .bashrc
│   ├── .gitconfig
│   ├── .config/{nvim,shell,tmux}/
│   └── .pixi/manifests/pixi-global.toml
├── packages/
│   ├── system/debian.txt
│   └── standalone.md
└── machines/
```
