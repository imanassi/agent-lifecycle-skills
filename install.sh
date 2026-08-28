#!/usr/bin/env bash
# slate — install /spec and /wrap into a project.
# https://github.com/imanassi/slate
#
#   ./install.sh /path/to/my-project
#
# Never overwrites an existing file — it reports skips instead, so re-running after you
# have customised the format specs is safe.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-}"

if [[ -z "$DEST" ]]; then
  echo "usage: $0 /path/to/project" >&2
  exit 1
fi
if [[ ! -d "$DEST" ]]; then
  echo "not a directory: $DEST" >&2
  exit 1
fi

copy() {
  local rel="$1" target="$DEST/$1"
  if [[ -e "$target" ]]; then
    echo "  skip    $rel (already exists)"
    return
  fi
  mkdir -p "$(dirname "$target")"
  cp "$SRC/$rel" "$target"
  echo "  create  $rel"
}

echo "Installing /spec and /wrap into $DEST"
copy "docs/specs/README.md"
copy "docs/specs/_TEMPLATE.md"
copy "docs/sessions/README.md"
copy "docs/sessions/_TEMPLATE.md"
copy ".agents/skills/spec/SKILL.md"
copy ".agents/skills/wrap/SKILL.md"
copy ".claude/skills/spec/SKILL.md"
copy ".claude/skills/wrap/SKILL.md"

if [[ -f "$DEST/AGENTS.md" ]] && grep -q "Specs and session wraps" "$DEST/AGENTS.md" 2>/dev/null; then
  echo "  skip    AGENTS.md (already wired up)"
else
  # Strip the leading HTML comment block before appending.
  sed '1,/^-->$/d' "$SRC/AGENTS.md.snippet" >> "$DEST/AGENTS.md"
  echo "  append  AGENTS.md"
fi

cat <<'EOM'

Done.

  Claude Code, Cursor   /spec   /wrap
  Codex CLI             $spec   $wrap
  Anything else         AGENTS.md tells it what to do

Next:
  1. Read docs/specs/README.md and docs/sessions/README.md and adjust them to your
     taste — they are the single source of truth; the command files just point at them.
  2. Commit the lot.
EOM
