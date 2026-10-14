# Paste into Conductor → Settings → Organization → Cloud Computer → Install software,
# then choose Build computer. It runs once per build, as bash with set -euo pipefail, from
# the sandbox home directory. Every new cloud workspace starts from the finished build.
#
# Set these under Cloud Computer → Environment first:
#   OPENAI_API_KEY       Codex outside reviews (from 1Password; paste it in the UI yourself)
#   GSTACK_CODEX_MODEL   gpt-6-astra
#   GSTACK_EPHEMERAL     1   (gstack stops writing history to a disk that won't survive)

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

# This repo: use the Cloud Computer's clone if it's one of the configured repositories,
# otherwise clone it (works without credentials only if the repo is public).
INSTALL=$(find "$HOME" -maxdepth 3 -name install.sh -path '*agent-config/*' -print -quit)
if [ -z "$INSTALL" ]; then
  git clone https://github.com/tmwBuidls/agent-config.git "$HOME/agent-config"
  INSTALL="$HOME/agent-config/install.sh"
fi
bash "$INSTALL" --cloud

# Log Codex in from OPENAI_API_KEY unless it already is.
if ! codex login status >/dev/null 2>&1 && [ -n "${OPENAI_API_KEY:-}" ]; then
  "$G/gstack-codex-login"
fi
