#!/usr/bin/env bash
# Conductor Cloud Computer install script. Don't paste this file; paste the bootstrap from
# the README into Settings → Organization → Cloud Computer → Install software. The bootstrap
# clones this repo and runs this script once per build, from the sandbox home directory.
# Every new cloud workspace starts from the finished build.
#
# Set these under Cloud Computer → Environment first:
#   OPENAI_API_KEY       Codex outside reviews (from 1Password; paste it in the UI yourself)
#   GSTACK_CODEX_MODEL   gpt-6-astra
#   GSTACK_EPHEMERAL     1   (gstack stops writing history to a disk that won't survive)
#   GBRAIN_URL, GBRAIN_CC_TOKEN, GBRAIN_CX_TOKEN   brain connection (see connect-gbrain.sh)
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Bun: gstack's setup refuses anything older than 1.3.3.
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun" PATH="$HOME/.bun/bin:$PATH"
printf '%s\n' 'export BUN_INSTALL="$HOME/.bun"' 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.profile"

# Codex CLI for gstack's outside reviews, unless the image already has it.
command -v codex >/dev/null || npm install -g @openai/codex

# gstack
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
(cd "$HOME/.claude/skills/gstack" && ./setup --host claude -q)
G="$HOME/.claude/skills/gstack/bin"
"$G/gstack-config" set telemetry community
"$G/gstack-config" set proactive true
"$G/gstack-config" set routing_declined true

# Impeccable: the skill, then gstack's checksum-verified detector engine.
# If the first command stops to ask questions, check its --help for a non-interactive flag.
npx -y impeccable install
bun --no-env-file run "$G/gstack-design-detect.ts" install --host claude

bash "$REPO/install.sh" --cloud

# Log Codex in from OPENAI_API_KEY unless it already is.
if ! codex login status >/dev/null 2>&1 && [ -n "${OPENAI_API_KEY:-}" ]; then
  "$G/gstack-codex-login"
fi

# Brain (gbrain MCP) for Claude Code and Codex, from the GBRAIN_* variables.
bash "$REPO/cloud/connect-gbrain.sh"
