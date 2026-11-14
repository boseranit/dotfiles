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

After installing TPM, reload tmux and press `prefix + I`. Move plugins from an
older `~/.config/tmux/plugins/` to `~/.local/share/tmux/plugins/` unless the
destination already exists.

Portable tools are declared in `home/.pixi/manifests/pixi-global.toml`. Node.js
tracks the newest LTS major; Tree-sitter CLI tracks 0.27, whose parser ABI
Neovim 0.12 supports.

RTK v1 renamed `proxy` to `bypass`, removed `--ultra-compact`, and relicensed
the default binary; the `rtk-oss` edition remains Apache-licensed.

## tmux 3.8 (Debian / WSL)

Backports may lag the [upstream release](https://github.com/tmux/tmux/releases/tag/3.8).
Build it under `~/.local/opt`; `~/.local/bin` must precede `/usr/bin` on PATH:

```sh
sudo apt-get install -y bison libevent-dev libncurses-dev pkg-config
cd "$(mktemp -d)"
curl -fLO https://github.com/tmux/tmux/releases/download/3.8/tmux-3.8.tar.gz
echo 'e79c699c7e949dccd0a4a125e17b8d1261e311b16979dbc8eb34542f3966d82e  tmux-3.8.tar.gz' | sha256sum -c -
tar -xzf tmux-3.8.tar.gz && cd tmux-3.8
./configure --prefix="$HOME/.local/opt/tmux-3.8" && make -j"$(nproc)" && make install
mkdir -p ~/.local/bin && ln -sfn ~/.local/opt/tmux-3.8/bin/tmux ~/.local/bin/tmux
```

A running server keeps its version (`tmux display -p '#{version}'`) until it
restarts.

## Neovim 0.12.6

- Source: [GitHub release](https://github.com/neovim/neovim/releases/tag/v0.12.6)
- Linux: `nvim-linux-x86_64.tar.gz`, SHA-256 `474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87`, `~/.local/opt/nvim-0.12.6`
- Windows: `nvim-win64.zip`, SHA-256 `4e12b7103b601ffc8f25954b4da100f339faa73dccb69a5b135e897fa3d893ed`, `C:\tools\neovim-0.12.6`

## Oh My Pi scout-exec agent

`home/.omp/agent/agents/scout-exec.md` is bundled Scout (same structured output
and `@smol` model) plus `bash` and `eval` for read-only analysis. Both bootstraps
link only this file into `~/.omp/agent/agents/`; Windows uses a hard link, so the
repository must share a volume with `$HOME`. Select it with
`agent: "scout-exec"` in a fresh OMP session. Its no-write rule is
instruction-only: Bash and eval are not sandboxed.
