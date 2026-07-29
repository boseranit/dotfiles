# Home server

Debian 13 (Trixie), x86-64. Select with:

```sh
./bootstrap.sh --machine home-server
```

## Differences from the shared base

- The shell exposes the server's crypto source, artifact, scratch, and archive roots.
- Neovim omits VimTeX and custom TeX snippets.
- `latexmk` is not installed.

## Services

Service state belongs in a separate `homelab` repository. Reusable Compose
definitions belong under `services/`; `hosts/home-server/` contains only
service selection and host-specific mounts, ports, and networking. Secrets,
volumes, and backups remain outside Git.

## Data storage and ownership

This section is the Linux host contract for a rebuild. Application repositories
remain responsible for their own code, environments, and service units.

### Storage roles

The storage order is SSD, `/mnt/redbackup`, then `/mnt/data-backup`, from fastest
to slowest.

| Environment variable | Path | Role | Backup policy |
| --- | --- | --- | --- |
| `CRYPTO_DATA_ROOT` | `/mnt/redbackup/data` | Authoritative collector-owned source evidence on the faster HDD | Back up to `/mnt/data-backup` |
| `CRYPTO_ARTIFACT_ROOT` | `/home/boser/crypto-data` | Reusable promoted features, models, risk artifacts, and runtime state on the SSD | Reproducible; rebuild from source rather than treating as authoritative |
| `RESEARCH_SCRATCH_ROOT` | `/home/boser/scratch/research-data` | Active, disposable research scratch on the SSD | Exclude reproducible intermediates from backup |
| `RESEARCH_ARCHIVE_ROOT` | `/mnt/redbackup/experiment-data` | Retained terminal research outputs that should outlive SSD scratch | Back up outputs that are expensive or impossible to reproduce |
| — | `/mnt/data-backup/borg/crypto-data` | Unencrypted Borg repository on the slower HDD | Backup destination only; never a live working tree |

Keep derived research data outside `/mnt/redbackup/data`. Source-data permissions
are deliberately stricter than permissions for Boser's research outputs.

Personal files remain on the SSD and retain their separate Borg backup on
`/mnt/redbackup`; crypto-data backup uses the other HDD so its live and backup
copies are on different devices.

### Mount the HDDs

Create stable mount points and identify filesystems by UUID rather than `/dev/sdX`,
because device names may change after hardware or boot-order changes:

```sh
sudo install -d -o root -g root -m 0755 /mnt/redbackup /mnt/data-backup
sudo blkid
```

The current `/etc/fstab` entries are:

```fstab
# Faster live-data HDD
UUID=b2b608d4-3f1f-4148-9c5d-069d6568e2c0 /mnt/redbackup ext4 defaults,nofail 0 2

# Slower backup HDD
UUID=e12644f9-a19f-4cae-9ce7-7abeb50f87c4 /mnt/data-backup ext4 defaults,nofail,nodev,nosuid,noexec,x-systemd.device-timeout=10s 0 2
```

Reuse these UUIDs only when moving the same filesystems. Use the values reported by
`blkid` after replacing or reformatting a drive.

```sh
sudo systemctl daemon-reload
sudo mount -a
findmnt --mountpoint /mnt/redbackup
findmnt --mountpoint /mnt/data-backup
```

### Create the collector identity

`crypto-collector` is the non-login writer identity. `crypto-data` grants Boser
read access to protected source data without granting deletion rights.

```sh
sudo groupadd --system crypto-data
sudo useradd --system --create-home \
  --home-dir /home/crypto-collector \
  --shell /usr/sbin/nologin \
  --gid crypto-data \
  crypto-collector
sudo usermod -aG crypto-data boser
```

Log out and back in after adding Boser to the group. UID 999 and GID 987 were the
automatically assigned values on `vostro`; do not hard-code them on a new machine.

Make the service home root-owned so the collector cannot modify its own deployed
programs. Boser owns application checkouts and can update them, while the service
account only reads and executes them:

```sh
sudo chown root:root /home/crypto-collector
sudo chmod 0755 /home/crypto-collector
sudo install -d -o root -g root -m 0755 /home/crypto-collector/bin
sudo install -d -o boser -g boser -m 0755 /home/crypto-collector/app
sudo chmod -R go-w /home/crypto-collector/app
```

Application-specific installation continues from the application repository after
this identity and directory boundary exists.

### Protect collected source data

The parent is root-owned. Each protected dataset is owned by its collector, and
its set-group-ID directories retain the `crypto-data` group for new children:

```sh
sudo install -d -o root -g crypto-data -m 0750 /mnt/redbackup/data
sudo install -d -o crypto-collector -g crypto-data -m 2750 \
  /mnt/redbackup/data/hyperliquid

sudo chown -R crypto-collector:crypto-data /mnt/redbackup/data/hyperliquid
sudo find /mnt/redbackup/data/hyperliquid -type d -exec chmod 2750 {} +
sudo find /mnt/redbackup/data/hyperliquid -type f -exec chmod 0640 {} +
```

Writers for protected datasets must run as `crypto-collector` with umask `0027`.
That produces owner-writable, group-readable files (`0640`) and directories
(`0750`, inheriting set-group-ID). Boser can read the data but cannot alter or
delete it because `crypto-data` has no directory write permission. Root and the
collector account remain able to administer it.

Apply the same ownership pattern to `binance` and `coinmarketcap` only after their
scheduled writers also run as `crypto-collector`; do not make a Boser-run writer
read-only before migrating that writer.

No ACLs are required for this model.

### Keep research output separate

```sh
sudo install -d -o boser -g boser -m 0750 \
  /home/boser/crypto-data \
  /home/boser/scratch/research-data \
  /mnt/redbackup/experiment-data
```

Publish reusable features, models, risk estimates, and runtime state to
`CRYPTO_ARTIFACT_ROOT`. Use `RESEARCH_SCRATCH_ROOT` for active experiments and
caches, then move only retained terminal outputs to `RESEARCH_ARCHIVE_ROOT`. Never
put derived artifacts or research results inside `CRYPTO_DATA_ROOT`.

### Create the unencrypted backup repository

The Borg repository is root-owned because root must be able to read every protected
source artifact. `--encryption=none` is intentional; physical access to the backup
disk therefore grants access to its contents.

```sh
sudo install -d -o root -g root -m 0700 /mnt/data-backup/borg
sudo borg init --encryption=none /mnt/data-backup/borg/crypto-data
sudo borg create --stats --compression zstd,3 \
  '/mnt/data-backup/borg/crypto-data::initial-{now:%Y-%m-%dT%H-%M-%S}' \
  /mnt/redbackup/data/hyperliquid \
  /mnt/redbackup/experiment-data
sudo borg list /mnt/data-backup/borg/crypto-data
```

Do not run `borg init` when reattaching the existing repository. Add a periodic
root-run `borg create` job using the same source paths. A completed archive makes
later deletion recoverable; filesystem permissions and backups are separate
protections.

### Verify a rebuilt host

```sh
getent group crypto-data
getent passwd crypto-collector
id boser
id crypto-collector

stat -c '%A %a %U:%G %n' \
  /home/crypto-collector \
  /mnt/redbackup/data \
  /mnt/redbackup/data/hyperliquid \
  /home/boser/crypto-data \
  /home/boser/scratch/research-data \
  /mnt/redbackup/experiment-data

sudo -u boser test -r /mnt/redbackup/data/hyperliquid
sudo -u boser test ! -w /mnt/redbackup/data/hyperliquid
sudo -u crypto-collector test -w /mnt/redbackup/data/hyperliquid
sudo borg list --last 5 /mnt/data-backup/borg/crypto-data
```
