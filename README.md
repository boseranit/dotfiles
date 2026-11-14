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
| Personal hardware configuration and runbooks | `hardware/` |
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
including Pixi, tmux, and Neovim, then deploy the configuration:

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
home files that are meaningful on Windows. tmux and psmux both use
`~/.config/tmux/tmux.conf`; the bootstrap points psmux there through the user
`PSMUX_CONFIG_FILE` environment variable. Existing targets receive a
timestamped backup. It uses directory junctions and hard links, so it does not
require elevation or Developer Mode. Open a new terminal after bootstrapping so
the psmux aliases and environment variable are available.

## Updating tools and plugins

```sh
pixi self-update
pixi global update
nvim --headless '+Lazy! update' +qa
```

Run `:TSUpdate` after plugin updates and update installed Mason-owned servers
through `:Mason`. Python tools come from Pixi, not Mason. Neovim and tmux release
installation details live in [packages/standalone.md](packages/standalone.md);
Tree-sitter and smart-splits migration notes live in the
[editor README](home/.config/nvim/README.md).

TPM uses `~/.local/share/tmux/plugins/`; `prefix + U`, then `all`, updates
its plugins. Keep downloaded plugins outside the linked configuration directory.

## tmux input diagnostics and recovery

Mouse-report text such as `0;198;38M` at a shell prompt means mouse tracking
was left enabled. Reproducing this state in an isolated server left root-table
Ctrl-h/j/k/l navigation working: mouse tracking alone does not explain the
reported navigation failure. The original offending application is unconfirmed.

On Unix, navigation checks live foreground processes on the pane's tty, not
only `pane_current_command`: that format can report `bash` for
`printf … | fzf` after the pipeline leader exits. Stopped/background jobs
must not intercept navigation. Native Windows/psmux keeps its native format
checks and does not depend on Unix `ps`.

Before resetting an affected pane, capture its state. Run inside that pane,
or set `pane` to its ID from `tmux list-panes -a` in a healthy pane:

```sh
pane="$TMUX_PANE"
tmux display-message -p -t "$pane" 'pane=#{pane_id} cmd=#{pane_current_command} tty=#{pane_tty} mouse=#{mouse_any_flag} sgr=#{mouse_sgr_flag} mode=#{pane_in_mode}'
ps -o pid,ppid,pgid,tpgid,stat,comm -t "$(tmux display-message -p -t "$pane" '#{pane_tty}')"
tmux list-clients -F 'tty=#{client_tty} session=#{session_name} table=#{client_key_table} flags=#{client_flags}'
tmux list-keys -T root | grep -E 'C-[hjkl]'
```

At a shell prompt, `tmux send-keys -R -t "$pane"` resets pane terminal modes
and clears the visible screen. It does not terminate the shell. Alternatively:

```sh
printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'
```

Keep `mouse on`. No blanket prompt-reset hook is installed: it would hide
evidence without explaining the navigation failure. If tmux itself is stopped
or detached, restore the outer terminal with `reset`, inspect `jobs -l`, and
resume or reattach the client.

Foreground-process regression coverage (Linux, Bash and procps):

```sh
python3 -B -m unittest discover -s tests -p 'test_tmux_foreground.py' -v
```

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
