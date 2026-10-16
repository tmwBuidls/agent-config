# agent-config

My `/pipeline` command, its stage files, and the setup that installs them on my Mac and on
Conductor cloud workspaces. **This repo is the single source of truth.** `install.sh`
symlinks everything into place, so editing a file here changes it everywhere.

```
loop/stages/
  00-research.md       describe the system as it is (never sees the ticket)
  01-outline.md        cut the work into vertical slices   <- the slicing rules live here
  02-slice.md          build exactly one slice
  scope.md             the HOLD SCOPE contract every stage and worker follows
  design-context.md    UI baseline and where Impeccable fits
claude/commands/pipeline.md   Claude Code router          -> ~/.claude/commands/pipeline.md
codex/skills/loop/            Codex router                 -> ~/.codex/skills/loop
claude/CLAUDE.cloud.md        global instructions for cloud workspaces
cloud/install-software.sh     Cloud Computer install script (run by the bootstrap below)
cloud/connect-gbrain.sh       connects Claude Code + Codex to the brain from GBRAIN_* env vars
install.sh                    creates the symlinks (safe to rerun)
```

`install.sh` also links `~/.loop` and `~/.agent-config` to this repo, and points
`~/.claude/skills/impeccable` at the shared `~/.agents/skills/impeccable` install so Claude
Code and Codex use the same Impeccable version.

## Updates

The router's first step is `git -C ~/.agent-config pull --ff-only`. Push a change and every
machine picks it up on its next run. Stage files are read from disk mid-run, so they apply
immediately; a router change applies to the next run. `--ff-only` leaves local edits alone.

## Why it's laid out this way

The stage files are pure prompt: no frontmatter, no bash, no host-specific tool names. The
routers differ in tool availability, skill syntax, and frontmatter, so the split is shared
rules, separate routers. Keep stage files host-neutral; phrase capability differences
conditionally ("if your host supports subagents, ..."), and put anything host-specific in a router.

The stage files live outside `~/.claude/` because gstack's Codex review prompts tell Codex to
ignore everything under `~/.claude/`.

## What the router leaves to gstack

- **Codex model and effort.** gstack resolves the outside-review model (`GSTACK_CODEX_MODEL`,
  then `~/.codex/config.toml`) and runs reviews at effort `high`. Inspect with
  `~/.claude/skills/gstack/bin/gstack-models list`.
- **Skipping office hours.** `/autoplan` skips its office-hours offer in spawned sessions.
- **Design detection.** `/design-review` runs Impeccable's detector and suggests the matching
  `/impeccable` command for each deferred finding.

The router still sets `GSTACK_SESSION_KIND=spawned` on gstack workers (inside Conductor gstack
otherwise assumes a human is watching) and overrides `/autoplan`'s scope-expansion defaults
with `scope.md`.

## Models

Opus routes and implements, Sonnet does research, Fable writes the outline (two pages out,
and a bad slice cut costs every later slice). `/review` runs on Opus so its nested
adversarial subagent inherits Opus rather than Fable; Codex supplies the second model.

## Cloud setup

1. Under Cloud Computer → Environment, set `OPENAI_API_KEY`, `GSTACK_CODEX_MODEL=gpt-6-astra`
   and `GSTACK_EPHEMERAL=1`. For the brain, also set `GBRAIN_URL` (the brain host's `/mcp`
   URL), `GBRAIN_CC_TOKEN` (Claude Code login) and `GBRAIN_CX_TOKEN` (Codex login). Never
   commit these; this repo is public.
2. Paste this into Install software and choose Build computer:
   ```bash
   git clone https://github.com/tmwBuidls/agent-config.git "$HOME/agent-config"
   bash "$HOME/agent-config/cloud/install-software.sh"
   ```

The real script is `cloud/install-software.sh`, so edit it here, not in Conductor. Script
changes and gstack or Impeccable updates take effect on the next build. Router and stage file
changes reach existing cloud workspaces through the pull above.

## Brain

`cloud/connect-gbrain.sh` registers the `gbrain` MCP server for Claude Code and Codex from the
`GBRAIN_*` variables, then checks each login works (look for `login check HTTP 200` in the
build log). Brain logins can read the main brain and gstack but only write to gstack. On the
Mac, export the same three variables and run `bash ~/.agent-config/cloud/connect-gbrain.sh`.
