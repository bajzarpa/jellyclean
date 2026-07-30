# AGENTS.md — Base instructions for jellyfin-clean-orphans

## Commit & push policy
- Do NOT commit unless the user explicitly approves with one of:
  "lgtm", "y", "yes", "goahead", "commit", "looks good", "approved",
  or similar affirmative language.
- After a commit, wait for a separate approval before pushing.

## Constraints
- Zero pip dependencies — only Python stdlib allowed
- `install.sh` must remain POSIX `sh`-compatible (no bashisms)
- Keep the main script as a single file (`bin/jellyfin-clean-orphans`)
- Run `python3 -c "import py_compile; py_compile.compile('bin/jellyfin-clean-orphans', doraise=True)"` to verify syntax before any commit
