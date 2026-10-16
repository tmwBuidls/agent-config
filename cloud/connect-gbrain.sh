#!/usr/bin/env bash
# Connect Claude Code and Codex to Tom's gbrain. Nothing secret lives in this public repo:
# the brain address and both logins come from the environment.
#
# Set these under Cloud Computer → Environment (or export them on the Mac):
#   GBRAIN_URL        the brain's /mcp address
#   GBRAIN_CC_TOKEN   brain login for Claude Code
#   GBRAIN_CX_TOKEN   brain login for Codex
#
# Conductor passes Environment variables to workspaces at runtime, not to the build.
#   bash connect-gbrain.sh            build/setup: registers Claude Code by variable name,
#                                     installs the runtime hooks below, and registers Codex
#                                     straight away if GBRAIN_URL is already set
#   bash connect-gbrain.sh --runtime  (re)registers Codex with the real address; Codex can't
#                                     expand variables in its URL, so this runs at session
#                                     start from the hooks
# Safe to rerun; never fails the build.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

codex_sync() {
  [ -n "${GBRAIN_URL:-}" ] && command -v codex >/dev/null || return 0
  if ! grep -qF "url = \"$GBRAIN_URL\"" "$HOME/.codex/config.toml" 2>/dev/null; then
    codex mcp remove gbrain >/dev/null 2>&1 || true
    codex mcp add gbrain --url "$GBRAIN_URL" --bearer-token-env-var GBRAIN_CX_TOKEN >/dev/null 2>&1 \
      && echo "gbrain: Codex registered"
  fi
}

if [ "${1:-}" = "--runtime" ]; then codex_sync; exit 0; fi

# Claude Code (Conductor runs Claude Code, so this covers both). Single quotes keep the
# literal ${...} references in ~/.claude.json; Claude Code expands them when it starts.
if command -v claude >/dev/null; then
  claude mcp remove gbrain -s user >/dev/null 2>&1 || true
  claude mcp add gbrain -s user -t http '${GBRAIN_URL}' -H 'Authorization: Bearer ${GBRAIN_CC_TOKEN}' \
    >/dev/null && echo "gbrain: Claude Code registered (reads GBRAIN_URL and GBRAIN_CC_TOKEN at runtime)"
else
  echo "gbrain: claude CLI not found, skipped"
fi

# Runtime hooks for Codex: new shells, and every Claude Code session start (gstack runs
# Codex reviews from inside Claude Code).
HOOK="[ -n \"\${GBRAIN_URL:-}\" ] && bash \"$HERE/connect-gbrain.sh\" --runtime >/dev/null 2>&1 # gbrain-codex"
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  grep -q '# gbrain-codex' "$rc" 2>/dev/null || echo "$HOOK" >> "$rc"
done
if command -v python3 >/dev/null; then
  python3 - "$HERE/connect-gbrain.sh" <<'PY'
import json, os, sys
p = os.path.expanduser("~/.claude/settings.json")
try:
    s = json.load(open(p))
except Exception:
    s = {}
cmd = f'bash "{sys.argv[1]}" --runtime'
hooks = s.setdefault("hooks", {}).setdefault("SessionStart", [])
if not any(x.get("command") == cmd for h in hooks for x in h.get("hooks", [])):
    hooks.append({"hooks": [{"type": "command", "command": cmd}]})
    os.makedirs(os.path.dirname(p), exist_ok=True)
    json.dump(s, open(p, "w"), indent=2)
PY
  echo "gbrain: Codex runtime hooks installed"
fi
codex_sync

# Login check, only where the variables are present (workspaces and the Mac, not the build).
check() {
  local name="$1" token="$2" code
  if [ -z "${GBRAIN_URL:-}" ] || [ -z "$token" ]; then
    echo "gbrain: $name login not in this environment (fine during a build)"; return 0
  fi
  code=$(curl -s -m 15 -o /dev/null -w "%{http_code}" -X POST "$GBRAIN_URL" \
    -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' || true)
  echo "gbrain: $name login check HTTP ${code:-000} (200 = good)"
}
check "Claude Code" "${GBRAIN_CC_TOKEN:-}"
check "Codex" "${GBRAIN_CX_TOKEN:-}"
exit 0
