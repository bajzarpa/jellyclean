# jellyfin-clean-orphans

A small CLI tool for cleaning up orphaned rows in Jellyfin's `jellyfin.db`
(the newer EF-Core-based schema, `BaseItems` table) — for cases where files
were removed from disk (e.g. via Radarr/Sonarr) but Jellyfin's database
still references them, causing library scans to choke or show broken items.

Also includes a read-only report mode for tracking missing poster/artwork
records (`BaseItemImageInfos`) by item type, useful after a bulk
"replace images" refresh to see what's still missing.

## Install

No `git` required — this pulls the script straight from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/bajzarpa/jellyclean/main/install.sh | sudo sh
```

This downloads `bin/jellyfin-clean-orphans` and installs it to
`/usr/local/bin/jellyfin-clean-orphans`, so it's available as a global
command: `jellyfin-clean-orphans`.

To update later (or reinstall), just re-run the same command.

Requires `python3` (stdlib only — no extra pip packages needed) and either
`curl` or `wget` on the target machine.

### Alternative: clone the repo

If you'd rather have a local copy (e.g. to browse or edit the source):

```bash
git clone https://github.com/bajzarpa/jellyclean.git
cd jellyclean
sudo ./install.sh
```

`install.sh` always fetches the latest `bin/jellyfin-clean-orphans` from
GitHub and installs it to `/usr/local/bin` — same behavior whether you run
it locally or pipe it straight from curl. It doesn't use your local clone's
copy of the script, so a local clone is purely for reference/editing, not
required for installing.

## Usage

```bash
# Read-only: show how many items per type are missing an image record
jellyfin-clean-orphans --image-gap-report

# Scope the image gap report to one type
jellyfin-clean-orphans --filter "Movie" --image-gap-report

# Dry-run scan of the whole library for orphaned rows (path missing on disk)
jellyfin-clean-orphans --all --dry-run

# Dry-run scoped to a specific title/path substring
jellyfin-clean-orphans --filter "Dutton Ranch" --dry-run

# Actually delete orphaned rows (auto-backs up the DB first)
jellyfin-clean-orphans --filter "Dutton Ranch" --execute

# Full library cleanup + restart Jellyfin afterward, reporting service status
jellyfin-clean-orphans --all --execute --restart-jellyfin

# Point at a non-default DB location
jellyfin-clean-orphans --db /path/to/jellyfin.db --all --dry-run
```

### Flags

| Flag | Description |
|---|---|
| `--db PATH` | Path to `jellyfin.db` (default: `/var/lib/jellyfin/data/jellyfin.db`) |
| `--filter TEXT` | Substring match on `Path` (or `Type`, when combined with `--image-gap-report`) |
| `--all` | Scan the entire library for orphans, ignoring `--filter` |
| `--dry-run` | Default. Show what would be deleted without changing anything |
| `--execute` | Actually perform deletions (auto-backs up the DB first) |
| `--restart-jellyfin` | After a successful `--execute`, restart the `jellyfin` systemd service and print its status |
| `--image-gap-report` | Read-only. Report BaseItems counts vs. how many have an image record, grouped by type |

## How it works

- Discovers child tables with foreign keys pointing at `BaseItems.Id` via
  `PRAGMA foreign_key_list`, so it doesn't rely on hardcoded schema
  assumptions that can break across Jellyfin versions.
- Backs up the DB (timestamped `.bak` file next to the original) before any
  `--execute` run.
- Batches deletes in chunks of 500 to stay under SQLite's variable limit on
  large orphan sets.

## Safety notes

- Always run with `--dry-run` first and review the output before `--execute`.
- If a network share or mount is temporarily unavailable, files on it will
  look "orphaned" even though they're not — double check before deleting.
- Stop Jellyfin (or at least avoid running scans concurrently) while doing
  DB surgery, to avoid write conflicts.
