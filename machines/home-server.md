# Home server

This file is an inventory, not a provisioning script. Record only deliberate
differences from the shared Debian baseline when the host is configured.

## Intended baseline

- `packages/system/debian.txt`
- Selected files under `home/`
- Only the Pixi environments actually useful on the server

## Services

Immich, Seafile, compose files, secrets, volumes, and backups belong in a
separate `homelab` repository. Keep links or a short deployment pointer here,
not service state.
