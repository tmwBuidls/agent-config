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
cloud/install-software.sh     Conductor Cloud Computer install script
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
   and `GSTACK_EPHEMERAL=1`.
2. Add this repo under Cloud Computer → Repositories, or make it public so the script can
   clone it.
3. Paste `cloud/install-software.sh` into Install software and choose Build computer.

Stage file and router changes reach cloud workspaces through the pull above; gstack and
Impeccable updates need a rebuild.
