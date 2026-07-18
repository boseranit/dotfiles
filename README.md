# dotfiles

Minimal, reproducible configuration for Debian, WSL Debian, and Windows where
the same configuration is useful. The repository records desired state; it
does not try to turn every application into a bespoke installer.

## Sources of truth

| Concern | Source of truth |
| --- | --- |
| Shell, Neovim, tmux, and Git configuration | `home/` |
| Portable CLI tools such as jq and ripgrep | `home/.pixi/manifests/pixi-global.toml` |
| Essential OS packages | `packages/system/<distribution>.txt` |
| Upstream standalone installers | `packages/standalone.md` |
| Sparse per-machine differences | `machines/<machine>/` |
| Windows Terminal configuration | `windows/terminal/settings.json` |
| Services such as Immich and Seafile | A separate `homelab` repository |
| Secrets, data, caches, and installed binaries | Outside Git |

`home/` mirrors shared paths below `$HOME`. Bootstrap links those paths plus
one explicitly selected sparse machine profile, backing up conflicts first.
The selection is remembered as a symlink at
`~/.config/dotfiles/machine`. Bootstrap deliberately does not install packages
or services.

## Debian / WSL Debian setup

Install the small shared OS-level base:

```sh
sudo apt-get update
grep -Ev '^\s*(#|$)' packages/system/debian.txt |
  xargs sudo apt-get install -y
```

On WSL, also install its sparse package additions:

```sh
grep -Ev '^\s*(#|$)' machines/wsl-debian/packages/debian.txt |
  xargs sudo apt-get install -y
```

Install the standalone tools listed in [packages/standalone.md](packages/standalone.md),
including Pixi and Neovim, then deploy the configuration:

```sh
./bootstrap.sh --machine wsl-debian
pixi global sync
nvim --headless '+Lazy! sync' +qa
```

Later bootstrap runs reuse the selected profile, so `--machine` is optional.
Non-secret Git identity may be tracked in a profile's `gitconfig`. Private Git
configuration belongs in `~/.config/dotfiles/local/gitconfig`:

```ini
[user]
    name = Your Name
    email = you@example.com
```

Existing `~/.gitconfig.local` files remain supported for compatibility.

See [machines/wsl-debian](machines/wsl-debian/README.md) for this machine and
[home/.config/nvim/README.md](home/.config/nvim/README.md) for editor details.

## Windows setup

Install Git, Pixi, psmux, and the pinned Neovim release recorded in
[packages/standalone.md](packages/standalone.md). Native Tree-sitter parser
builds also need LLVM Clang and Strawberry Perl in their default locations;
Mason needs 7-Zip. Then clone the repository on the same drive as `$HOME` and
run from PowerShell:

```powershell
git clone https://github.com/boseranit/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
winget install --id marlocarlo.psmux --exact
.\bootstrap.ps1
pixi global sync
nvim --headless "+Lazy! sync" +qa
```

The PowerShell bootstrap maps Neovim to `%LOCALAPPDATA%\nvim`, Windows Terminal
settings to its packaged-app `LocalState` directory, and deploys the portable
home files that are meaningful on Windows. tmux uses
`~/.config/tmux/tmux.conf`; psmux's XDG config sources that same file. Existing
targets receive a timestamped backup. It uses directory junctions and hard
links, so it does not require elevation or Developer Mode.

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
├── machines/
│   ├── home-server/
│   └── wsl-debian/
├── windows/terminal/settings.json
└── packages/
    ├── system/debian.txt
    └── standalone.md
```
