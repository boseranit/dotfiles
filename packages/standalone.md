# Standalone tools

| Tool | Source | Install |
| --- | --- | --- |
| Pixi | Prefix.dev | `curl -fsSL https://pixi.sh/install.sh \| sh` |
| Codex | OpenAI | `curl -fsSL https://chatgpt.com/codex/install.sh \| sh` |
| Oh My Pi | [omp.sh](https://omp.sh) | `curl -fsSL https://omp.sh/install \| sh` |
| Oh My Pi (Windows) | [omp.sh](https://omp.sh) | `irm https://omp.sh/install.ps1 \| iex` |
| RTK | Upstream `install.sh` | Installer URL not yet recorded |
| QMK (WSL) | QMK | `curl -fsSL https://install.qmk.fm \| sh` |
| psmux (Windows) | WinGet | `winget install --id marlocarlo.psmux --exact` |
| Tmux Plugin Manager | GitHub | `git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm` |

After installing TPM, reload tmux and press `prefix + I` to install the plugins
declared in `tmux.conf`. Use `prefix + U` to update them.

## Oh My Pi executable Scout

The canonical definition is `home/.omp/agent/agents/scout-exec.md`. Both
bootstraps install it at `~/.omp/agent/agents/scout-exec.md`: a symlink on Linux
and a hard link on Windows. Only this agent file is managed; OMP user settings
and other user agents remain untouched. Windows hard links require the
repository and home directory to be on the same volume.

It retains bundled Scout's structured output and `model: "@smol"` selection,
with `bash` and `eval` added for read-only inspection and analysis. Regular
`scout` remains unchanged. The definition uses OMP's `thinkingLevel` and
`readSummarize` frontmatter keys.

Start a fresh OMP session and select `agent: "scout-exec"` in a task call, or
ask OMP to use `scout-exec` for an investigation requiring shell/Python analysis.
Python runs through `eval` with `language: "py"`; check interpreter availability
with `omp setup python --check --json`. For inline Python through Bash, use an
installed Python 3 executable with `-B`: `python3` on Linux, or `python` when
available on Windows. Debian's `python3` package does not provide a `python`
alias by default.

The agent forbids file changes, state-changing commands, on-disk scripts,
temporary files, and dependency installation. Python analysis stays in memory
with bytecode creation disabled. It has no `edit` or `write` tool, but Bash/eval
are not sandboxed: the no-write rule is instruction-based, not filesystem-enforced.

## Neovim 0.12.4

- Source: [GitHub release](https://github.com/neovim/neovim/releases/tag/v0.12.4)
- Linux: `nvim-linux-x86_64.tar.gz`, SHA-256 `012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628`, `~/.local/opt/nvim-0.12.4`
- Windows: `nvim-win64.zip`, SHA-256 `9fc3572829ffd13debb6e32555da2c8cc02555568260a9fc4cf1f65bbcca319c`, `C:\tools\neovim-0.12.4`

Portable tools are declared in `home/.pixi/manifests/pixi-global.toml`.
