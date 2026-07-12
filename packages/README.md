# Packages

This directory records package provenance without hiding installation behind a
large machine-specific script.

- `system/<distribution>.txt` contains the shared OS-level foundation.
- `../machines/<machine>/packages/` contains sparse package additions.
- `standalone.md` records tools installed directly from an upstream publisher.
- Portable command-line tools belong in the tracked Pixi global manifest at
  `home/.pixi/manifests/pixi-global.toml`.

Applications used only by one machine belong in that machine profile, not in
the shared system package list.

## Rule of thumb

1. Use APT for the OS foundation, libraries, drivers, daemons, and desktop
   integration.
2. Use Pixi global for portable CLI tools available on conda-forge.
3. Use an upstream standalone release when APT is too old or upstream is the
   canonical distribution channel.
4. Keep language/project dependencies in the project that uses them.
5. Record machine-only applications in `machines/<machine>/`; do not add them
   globally.

Prefer one owner per tool. Do not install the same executable through APT,
Pixi, and a standalone installer.

## Python ownership

APT owns the host `python3` interpreter for operating-system scripts and basic
tool compatibility. Do not install project packages into it with `pip`.
Project Python versions, libraries, and development tools belong in each
project's Pixi manifest and lock file. `python3-venv` is optional and is not
part of the shared baseline while projects use Pixi.
