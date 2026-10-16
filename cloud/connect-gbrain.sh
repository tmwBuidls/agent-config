#!/usr/bin/env bash
# Connect Claude Code and Codex to Tom's gbrain (the brain service on Railway).
# Reads everything from the environment; no secrets live in this repo (it is public).
#
# Set these under Cloud Computer → Environment (or export them on the Mac):
#   GBRAIN_URL        https://<brain host>/mcp   (/mcp is added if missing)
#   GBRAIN_CC_TOKEN   brain login for Claude Code
#   GBRAIN_CX_TOKEN   brain login for Codex
# Both logins read the main brain + gstack and write only to gstack.
# Safe to rerun; skips quietly when the variables aren't set; never fails the build.
set -uo pipefail

if [ -z "${GBRAIN_URL:-}" ]; then
  echo "gbrain: GBRAIN_URL not set, skipping"
  exit 0
fi
URL="${GBRAIN_URL%/}"
case "$URL" in */mcp) ;; *) URL="$URL/mcp" ;; esac

# Claude Code (Conductor runs Claude Code, so this covers both). The header is stored in
# ~/.claude.json; `claude mcp add` has no env-var indirection for headers.
if [ -n "${GBRAIN_CC_TOKEN:-}" ] && command -v claude >/dev/null; then
  claude mcp remove gbrain -s user >/dev/null 2>&1 || true
  claude mcp add gbrain -s user -t http "$URL" -H "Authorization: Bearer $GBRAIN_CC_TOKEN" \
    >/dev/null && echo "gbrain: Claude Code connected"
else
  echo "gbrain: Claude Code skipped (no GBRAIN_CC_TOKEN or no claude CLI)"
fi

# Codex reads the token from the environment at runtime; only the variable *name* is stored.
if [ -n "${GBRAIN_CX_TOKEN:-}" ] && command -v codex >/dev/null; then
  codex mcp remove gbrain >/dev/null 2>&1 || true
  codex mcp add gbrain --url "$URL" --bearer-token-env-var GBRAIN_CX_TOKEN \
    >/dev/null && echo "gbrain: Codex connected"
else
  echo "gbrain: Codex skipped (no GBRAIN_CX_TOKEN or no codex CLI)"
fi

# Smoke test each login that is set: 200 means it works.
check() {
  local name="$1" token="$2" code
  [ -n "$token" ] || return 0
  code=$(curl -s -m 15 -o /dev/null -w "%{http_code}" -X POST "$URL" \
    -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' || true)
  echo "gbrain: $name login check HTTP ${code:-000} (200 = good)"
}
check "Claude Code" "${GBRAIN_CC_TOKEN:-}"
check "Codex" "${GBRAIN_CX_TOKEN:-}"
exit 0
