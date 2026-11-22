# dotfiles

Minimal, reproducible configuration for Debian, WSL Debian, and Windows. The
repository records desired state; it is not a bespoke installer.

## Sources of truth

| Concern | Source of truth |
| --- | --- |
| Shell, Neovim, tmux, Git, and OMP agent configuration | `home/` |
| Portable CLI tools such as jq and ripgrep | `home/.pixi/manifests/pixi-global.toml` |
| Shared Debian admin packages | `packages/system/<distribution>.txt` |
| Upstream standalone installers | `packages/standalone.md` |
| Sparse per-machine differences | `machines/<machine>/` |
| `vostro` host base: filesystem mounts, collector identity, and research Borg storage | [`machines/home-server/`](machines/home-server/README.md) |
| Windows Terminal configuration | `windows/terminal/settings.json` |
| Personal hardware configuration and runbooks | `hardware/` |
| Home-server deployments: service dependencies, Compose, WireGuard, ingress, app data paths, and app backup schedules | [homelab](https://github.com/boseranit/homelab) |
| Secrets, data, caches, and installed binaries | Outside Git |

`home/` mirrors paths below `$HOME`, including the OMP
[`scout-exec` agent](packages/standalone.md#oh-my-pi-scout-exec-agent).
Bootstrap links them plus one selected machine profile (remembered at
`~/.config/dotfiles/machine`), backing up conflicts first. It never installs
packages or services.

## Debian / WSL Debian setup

```sh
sudo apt-get update
grep -Ev '^\s*(#|$)' packages/system/debian.txt | xargs sudo apt-get install -y
# WSL only:
grep -Ev '^\s*(#|$)' machines/wsl-debian/packages/debian.txt | xargs sudo apt-get install -y
```

Install the [standalone tools](packages/standalone.md), including Pixi and
Neovim, then:

```sh
./bootstrap.sh --machine wsl-debian  # later runs reuse the profile
pixi global sync
nvim --headless '+Lazy! sync' +qa
```

A profile's `gitconfig` may hold non-secret Git identity. Private settings go in
`~/.config/dotfiles/local/gitconfig` (legacy `~/.gitconfig.local` still works):

```ini
[user]
    name = Your Name
    email = you@example.com
```

See [machines/wsl-debian](machines/wsl-debian/README.md) and the
[editor README](home/.config/nvim/README.md).

## Windows setup

Install Git, Pixi, and the pinned Neovim from
[packages/standalone.md](packages/standalone.md). Tree-sitter parser builds need
LLVM Clang and Strawberry Perl in their default locations; Mason needs 7-Zip.
Clone on the same drive as `$HOME`, then in PowerShell:

```powershell
git clone https://github.com/boseranit/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
winget install --id marlocarlo.psmux --exact
.\bootstrap.ps1
pixi global sync
nvim --headless "+Lazy! sync" +qa
```

The bootstrap uses junctions and hard links (no elevation or Developer Mode),
maps Neovim to `%LOCALAPPDATA%\nvim` and Windows Terminal settings to its
`LocalState`, and points psmux at `~/.config/tmux/tmux.conf` through
`PSMUX_CONFIG_FILE`. Open a new terminal afterwards.

## Updating

```sh
pixi self-update
pixi global update
nvim --headless '+Lazy! update' +qa
```

Then run `:TSUpdate`, update Mason-owned servers in `:Mason` (Python tools come
from Pixi), and update tmux plugins with `prefix + U`.

## tmux troubleshooting

Text such as `0;198;38M` at a prompt means an application left mouse tracking
on. Reset it with `tmux send-keys -R` (also clears the pane) or:

```sh
printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'
```

On Unix, Ctrl-h/j/k/l pass through when a foreground process on the pane's tty
is Neovim or fzf; Alt-h/j/k/l only for Neovim. List those processes with
`ps -o stat,comm -t "$(tmux display -p '#{pane_tty}')"`.

## Repository layout

```text
.
├── bootstrap.sh
├── bootstrap.ps1
├── home/
│   ├── .bashrc
│   ├── .gitconfig
│   ├── .config/{nvim,shell,tmux}/
│   ├── .omp/agent/agents/scout-exec.md
│   └── .pixi/manifests/pixi-global.toml
├── hardware/
│   └── keyboards/iris-rev7/
├── machines/
│   ├── home-server/
│   └── wsl-debian/
├── windows/terminal/settings.json
└── packages/
    ├── system/debian.txt
    └── standalone.md
```
