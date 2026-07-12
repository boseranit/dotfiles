# Machine profiles

Each directory is a sparse set of tracked differences from the shared `home/`
configuration. The Unix bootstrap selects one profile explicitly and remembers
it at `~/.config/dotfiles/machine`. Windows uses the shared base directly until
it has a tracked difference.

Profile files are optional:

- `shell.sh` adds non-secret interactive-shell state.
- `gitconfig` adds non-secret Git policy or identity.
- `nvim.lua` changes editor behavior.
- `packages/<distribution>.txt` adds operating-system packages.

Secrets and credential material belong under `~/.config/dotfiles/local/`, not
in a machine profile.
