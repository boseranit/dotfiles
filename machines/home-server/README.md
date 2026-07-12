# Home server

Debian 13 (Trixie), x86-64. Select with:

```sh
./bootstrap.sh --machine home-server
```

## Differences from the shared base

- The shell exposes the server's Hyperliquid data root.
- Neovim omits VimTeX and custom TeX snippets.
- `latexmk` is not installed.

## Services

Service state belongs in a separate `homelab` repository. Reusable Compose
definitions belong under `services/`; `hosts/home-server/` contains only
service selection and host-specific mounts, ports, and networking. Secrets,
volumes, and backups remain outside Git.
