# ~/.loop — shared stage files for the `/loop` command

Host-neutral home for the `/loop` pipeline's stage prompts. **This is the single source of
truth.** Both the Claude Code and Codex routers read these same files.

```
~/.loop/stages/
  00-research.md    describe the system as it is
  01-outline.md     cut it into vertical slices        <- the doctrine lives here
  02-slice.md       build exactly one slice

~/.claude/commands/loop.md      Claude Code router
~/.claude/loop/stages           -> symlink to ~/.loop/stages
~/.codex/skills/loop/SKILL.md   Codex router
```

## Why it's laid out this way

The stage files are pure prompt — no frontmatter, no bash, no host-specific tool names. The
routers are not: they differ in tool availability, skill invocation syntax, and frontmatter
schema. So the split is **shared doctrine, duplicated router**. The vertical-slicing rules —
the three tests, complete core scenario, never-hoist, the rejection list — exist in exactly one file.

Both routers hold scope by default and override autoplan's selective-expansion defaults.
Office hours is opt-in; a short design note is used only when material approach decisions
need settling. Slices deliver coherent releasable outcomes with no minimum count, and their
checkpoint summary opens with a 1–2 sentence overview of the implementation approach.

Deliberately **not** under `~/.claude/`: gstack's Codex review prompts instruct Codex to ignore
everything under `~/.claude/`, so shared content can't live there.

## Editing

Edit `~/.loop/stages/*.md` directly — both hosts pick the change up on their next run, since
each stage is read from disk at invocation.

Keep them host-neutral. Where a capability differs, phrase it conditionally ("if your host
supports subagents, ...") rather than naming a specific tool. Anything genuinely host-specific
belongs in the router, not here.

## Router differences

Codex uses Astra as its preferred lead, outline, complex implementation, and review model,
with Terra research workers and Sol workers for routine implementation and QA. It uses
native subagents when available and falls back inline when a host lacks the capability.
Claude uses Opus for coordination and implementation, Sonnet for research, and Fable for
outline and review. Both routers continue through clean slices and support `--strict`.

The Codex router requests a bounded Claude outside review; the Claude router explicitly
selects Astra for its Codex review commands. See each router for dispatch details and
fallback behavior. Model selection in an existing host session overrides the CLI default:
start Codex with `codex -m gpt-6-astra`, or select Astra in Conductor's model picker.
