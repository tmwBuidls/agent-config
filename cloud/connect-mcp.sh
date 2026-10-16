#!/usr/bin/env bash
# Connect Claude Code and Codex to Tom's remote MCP servers. Nothing secret lives in this
# public repo: every address and login comes from the environment.
#
# Set these under Cloud Computer → Environment (or export them on the Mac):
#   GBRAIN_URL        the brain's /mcp address
#   GBRAIN_CC_TOKEN   brain login for Claude Code
#   GBRAIN_CX_TOKEN   brain login for Codex
#   EXECUTOR_URL      Executor's /mcp address
#   EXECUTOR_API_KEY  an Executor API key (Settings → API keys); both agents share it
#
# Conductor passes Environment variables to workspaces at runtime, not to the build.
#   bash connect-mcp.sh --build    build: registers Claude Code by variable name, installs
#                                  the runtime hooks below, registers Codex if it can
#   bash connect-mcp.sh            Mac: same, but only for servers whose URL is set, so an
#                                  existing OAuth login isn't replaced by an empty variable
#   bash connect-mcp.sh --runtime  (re)registers Codex with the real addresses; Codex can't
#                                  expand variables in its URL, so this runs at session
#                                  start from the hooks
# Safe to rerun; never fails the build.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-}"

# name, URL variable, Claude Code login variable, Codex login variable
SERVERS=(
  "gbrain   GBRAIN_URL   GBRAIN_CC_TOKEN  GBRAIN_CX_TOKEN"
  "executor EXECUTOR_URL EXECUTOR_API_KEY EXECUTOR_API_KEY"
)

codex_sync() {
  local name="$1" url="${!2:-}" cx="$3"
  [ -n "$url" ] && command -v codex >/dev/null || return 0
  if ! grep -qF "url = \"$url\"" "$HOME/.codex/config.toml" 2>/dev/null; then
    codex mcp remove "$name" >/dev/null 2>&1 || true
    codex mcp add "$name" --url "$url" --bearer-token-env-var "$cx" >/dev/null 2>&1 \
      && echo "$name: Codex registered"
  fi
}

if [ "$MODE" = "--runtime" ]; then
  for s in "${SERVERS[@]}"; do set -- $s; codex_sync "$1" "$2" "$4"; done
  exit 0
fi

# Claude Code (Conductor runs Claude Code, so this covers both). Single quotes keep the
# literal ${...} references in ~/.claude.json; Claude Code expands them when it starts.
for s in "${SERVERS[@]}"; do
  set -- $s
  if ! command -v claude >/dev/null; then echo "$1: claude CLI not found, skipped"; continue; fi
  if [ "$MODE" != "--build" ] && [ -z "${!2:-}" ]; then echo "$1: $2 not set, left as is"; continue; fi
  claude mcp remove "$1" -s user >/dev/null 2>&1 || true
  claude mcp add "$1" -s user -t http "\${$2}" -H "Authorization: Bearer \${$3}" \
    >/dev/null && echo "$1: Claude Code registered (reads $2 and $3 at runtime)"
done

# Runtime hooks for Codex: new shells, and every Claude Code session start (gstack runs
# Codex reviews from inside Claude Code).
HOOK="bash \"$HERE/connect-mcp.sh\" --runtime >/dev/null 2>&1 # agent-config-mcp"
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  grep -q '# agent-config-mcp' "$rc" 2>/dev/null || echo "$HOOK" >> "$rc"
done
if command -v python3 >/dev/null; then
  python3 - "$HERE/connect-mcp.sh" <<'PY'
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
  echo "Codex runtime hooks installed"
fi
for s in "${SERVERS[@]}"; do set -- $s; codex_sync "$1" "$2" "$4"; done

# Login check, only where the variables are present (workspaces and the Mac, not the build).
check() {
  local label="$1" url="${!2:-}" token="${!3:-}" code
  if [ -z "$url" ] || [ -z "$token" ]; then
    echo "$label login not in this environment (fine during a build)"; return 0
  fi
  code=$(curl -s -m 15 -o /dev/null -w "%{http_code}" -X POST "$url" \
    -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' || true)
  echo "$label login check HTTP ${code:-000} (200 = good)"
}
for s in "${SERVERS[@]}"; do
  set -- $s
  if [ "$3" = "$4" ]; then
    check "$1:" "$2" "$3"
  else
    check "$1: Claude Code" "$2" "$3"; check "$1: Codex" "$2" "$4"
  fi
done
exit 0
