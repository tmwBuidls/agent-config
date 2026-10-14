#!/usr/bin/env bash
# Link this repo into the places Claude Code and Codex read from. Safe to rerun.
# Anything already at a target that isn't a symlink is moved to ~/.agent-config-backup/<time>/
# (outside the skills folders, so a backed-up skill can't load twice).
#
#   ./install.sh           on the Mac
#   ./install.sh --cloud   on a Conductor Cloud Computer; also installs the cloud CLAUDE.md
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.agent-config-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/$(echo "${dst#"$HOME"/}" | tr '/' '_')"
    echo "backed up $dst to $BACKUP"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
}

link "$REPO"                              "$HOME/.agent-config"
link "$REPO/loop"                         "$HOME/.loop"
link "$REPO/loop/stages"                  "$HOME/.claude/loop/stages"
link "$REPO/claude/commands/pipeline.md"  "$HOME/.claude/commands/pipeline.md"
link "$REPO/codex/skills/loop"            "$HOME/.codex/skills/loop"

# Claude Code and Codex share one Impeccable install (the one `npx impeccable install` updates).
if [ -d "$HOME/.agents/skills/impeccable" ]; then
  link "../../.agents/skills/impeccable"  "$HOME/.claude/skills/impeccable"
fi

if [ "${1:-}" = "--cloud" ]; then
  link "$REPO/claude/CLAUDE.cloud.md"     "$HOME/.claude/CLAUDE.md"
fi
