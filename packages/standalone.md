# Standalone tools

| Tool | Source | Install |
| --- | --- | --- |
| Pixi | Prefix.dev | `curl -fsSL https://pixi.sh/install.sh \| sh` |
| Codex | OpenAI | `curl -fsSL https://chatgpt.com/codex/install.sh \| sh` |
| Oh My Pi | [omp.sh](https://omp.sh) | `curl -fsSL https://omp.sh/install \| sh` |
| Oh My Pi (Windows) | [omp.sh](https://omp.sh) | `irm https://omp.sh/install.ps1 \| iex` |
| RTK | [Upstream installer](https://github.com/rtk-ai/rtk) | `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh \| sh` |
| QMK (WSL) | QMK | `curl -fsSL https://install.qmk.fm \| sh` |
| psmux (Windows) | WinGet | `winget install --id marlocarlo.psmux --exact` |
| Tmux Plugin Manager | GitHub | `git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm` |

After installing TPM, reload tmux and press `prefix + I` to install the plugins
declared in `tmux.conf`. Use `prefix + U` to update them.

TPM and its plugins live outside the linked configuration tree, under
`~/.local/share/tmux/plugins/`. If an older installation uses
`~/.config/tmux/plugins/`, move that directory to the new location before
reloading; do not replace an existing destination.

## tmux 3.8 (Debian / WSL)

Backports may lag the [upstream release](https://github.com/tmux/tmux/releases/tag/3.8).
Install the release under `~/.local/opt`, ahead of `/usr/bin/tmux` on PATH:

```sh
sudo apt-get install -y bison libevent-dev libncurses-dev pkg-config
work="$(mktemp -d)"
cd "$work"
curl -fLO https://github.com/tmux/tmux/releases/download/3.8/tmux-3.8.tar.gz
printf '%s  %s\n' e79c699c7e949dccd0a4a125e17b8d1261e311b16979dbc8eb34542f3966d82e tmux-3.8.tar.gz | sha256sum -c -
tar -xzf tmux-3.8.tar.gz
cd tmux-3.8
./configure --prefix="$HOME/.local/opt/tmux-3.8"
make -j"$(nproc)"
make install
mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/.local/opt/tmux-3.8/bin/tmux" "$HOME/.local/bin/tmux"
```

Replacing the client does not upgrade an existing server. `tmux -V` reports
the client; `tmux display-message -p '#{version}'` reports the server. Preserve
busy sessions; `tmux -L fresh new-session` starts a separate upgraded server
without terminating them. Reload configuration with
`tmux source-file ~/.config/tmux/tmux.conf`.

## Neovim 0.12.6

- Source: [GitHub release](https://github.com/neovim/neovim/releases/tag/v0.12.6)
- Linux: `nvim-linux-x86_64.tar.gz`, SHA-256 `474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87`, `~/.local/opt/nvim-0.12.6`
- Windows: `nvim-win64.zip`, SHA-256 `4e12b7103b601ffc8f25954b4da100f339faa73dccb69a5b135e897fa3d893ed`, `C:\tools\neovim-0.12.6`

Portable tools are declared in `home/.pixi/manifests/pixi-global.toml`.

Use `pixi self-update` and `pixi global update` for installed CLI upgrades.
Node.js tracks the newest LTS major, not prereleases. Tree-sitter CLI tracks
0.27; its generated-parser ABI remains compatible with the configured Neovim.
See the [Node release policy](https://nodejs.org/en/about/previous-releases)
and [Tree-sitter 0.27 notes](https://github.com/tree-sitter/tree-sitter/releases/tag/v0.27.0).

RTK v1 renamed `proxy` to `bypass`, removed `--ultra-compact`, and changed the
default binary's license. The upstream `rtk-oss` edition remains Apache-licensed;
updating the executable does not require regenerating agent hooks or settings.
