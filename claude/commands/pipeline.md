---
description: Research → vertical-slice outline → per-slice implement → QA → review → ship, through gstack. Stops at the artifacts, not the decisions.
argument-hint: "[feature, issue #, or spec path] · [--auto|--strict|--oneshot] · or research|outline|implement to re-enter"
allowed-tools: Skill, Agent, Read, Write, Edit, Glob, Grep, Bash
model: opus
---

# /pipeline — gstack pipeline, artifact-gated

Drive a feature from request to an open PR by invoking gstack skills. Never reimplement what
gstack already does. Stop on documents, not decisions: reading a two-page outline is cheap,
adjudicating implementation choices is not.

## The request
$ARGUMENTS

If it's a file path or issue number, read it first. Parse leading flags; the rest is the request.

**Flags:** `--auto` skips the outline checkpoint and slice stops (never the scope contract or
visual sign-off) · `--strict` stops after every slice · `--oneshot` forces the oneshot path.
**Re-entry:** a request of exactly `research`, `outline`, or `implement` resumes that phase from
the existing artifacts, e.g. after I edit one by hand.

## Setup

```bash
git -C ~/.agent-config pull --ff-only -q 2>/dev/null || true
G=~/.claude/skills/gstack/bin
ROOT=$("$G/gstack-paths" --get GSTACK_STATE_ROOT)
SLUG=$("$G/gstack-slug" | sed -n 's/^SLUG=//p')
BRANCH=$(git rev-parse --abbrev-ref HEAD | tr '/' '-'); DT=$(date +%Y%m%d-%H%M%S); U=$(whoami)
A="$ROOT/projects/$SLUG"; mkdir -p "$A"
```

Artifacts go in `$A` so gstack skills find them: `{U}-{BRANCH}-research-{DT}.md` and
`{U}-{BRANCH}-outline-{DT}.md` (the plan file for everything downstream).

When `CONDUCTOR_IS_LOCAL=0` (a cloud workspace), I can't open files in the sandbox: at each
checkpoint, paste the artifact's content rather than only its path.

## Contracts

**Scope.** `~/.loop/stages/scope.md` binds every phase and worker. Pass its path to each one.

**Escalation.** Classify each decision you face:
- REVERSIBLE (changeable later with no migration, data loss, or broken published contract) →
  decide, log one line to `DECISIONS.md`, continue.
- LOAD-BEARING with a recommendation → decide, record it under "⚠ Consequential decisions", continue.
- LOAD-BEARING with no winner, because it turns on product taste, business, cost, or risk → stop and ask:
  > I'd choose **X** because … The case for **Y** is … This is a <product / cost / risk> call I shouldn't make alone — which?

Never ask what you could answer. Architecture and product decisions go into the current artifact
for its checkpoint instead of being decided mid-flight.

**Workers.** Every Agent call uses `subagent_type: "general-purpose"`, `run_in_background: false`
(the phase needs the result before continuing), and the model its phase names. Put anything whose
value to me is a summary in a worker; keep inline only what I must see verbatim or visually.
A worker that invokes a gstack skill starts its prompt with this preamble, because inside
Conductor gstack otherwise assumes a human is watching and stops at its first question:

> You are a spawned session; no human reads your output mid-run. Prefix your gstack skill
> invocation with `GSTACK_SESSION_KIND=spawned`. Follow `~/.loop/stages/scope.md`; it overrides
> the skill's scope-expansion defaults. At every gate, auto-choose the recommended option
> consistent with it and never render a decision brief. Return what's asked below plus every
> option you auto-chose.

gstack picks the Codex model and effort for its outside reviews; don't pass model flags. If a
Codex pass is unavailable, report that rather than substituting anything.

## Phase 0 — Triage

Read the request and enough code to size it.
- **Oneshot** (bugfix, copy change, single file, no new surface): write a one-slice outline
  yourself and go to Phase 3. Say so in one line.
- **Full** (new surface, dependency, or data model; cross-cutting): continue.

For a user-visible change, read `~/.loop/stages/design-context.md` now and establish its
baseline before any UI worker, on either path.

## Phase 1 — Research (Sonnet)

Worker, `model: "sonnet"`: *"Read `~/.loop/stages/00-research.md` and follow it in full. Pin any
research-question subagents to `model: 'sonnet'`."* Pass the artifact path and the research
areas, **never the ticket text**. Always include how the system is run and observed as an area;
the outline slices by where a change becomes visible.

## Phase 2 — Outline and review

1. **Outline**: worker, `model: "fable"`: *"Read `~/.loop/stages/01-outline.md` and follow it in
   full."* Pass the request, research path, scope path, any UI baseline, and the output path.
   Unresolved product or architecture choices go in the outline's Design decisions. Run
   `/office-hours` only if I ask for it.
2. **Verticality gate**: read the outline yourself. Check every slice against the stage file's
   three tests, sizing, and rejection list; rerun the stage with the failures named until it
   passes. Reviewers optimise a horizontal plan instead of fixing it.
3. **/autoplan**: worker, `model: "opus"`, never inline (it loads several large review skills
   that would stay in this context for the rest of the run). Preamble, then: *"Invoke /autoplan on
   `<outline path>`. Slices are fixed as vertical: you may reorder or resize them, but decline
   'build the foundation / API / token layer first'. Return the test-plan path, what changed in
   the outline, every issue a human should see, and Codex's output verbatim."* Afterwards,
   remove any addition the scope contract doesn't justify.

**CHECKPOINT — stop.** A 1–2 sentence overview of the implementation approach, then the slices
as name + one-line demo statement, then material review findings, justified scope additions, and
the ⚠ list. Keep file inventories in the artifact. Wait.

## Phase 3 — Implement, one slice at a time

For each slice in order:
1. Worker, `model: "opus"`: *"Read `~/.loop/stages/02-slice.md` and follow it in full for slice N."*
   For UI slices, include the baseline.
2. Gate: typecheck, lint, tests. Fix and rerun, at most 3 attempts; if still red, stop and say
   exactly what blocks.
3. Confirm the slice's Demo sentence is true. If the worker didn't run it, run it yourself.
4. Commit the slice alone, with a message naming it.
5. Report the demo and whether it was verified, what landed, files touched, decisions logged.
   Stop only if the slice logged a load-bearing decision, flagged an outline boundary as wrong,
   or touched a user-visible surface (`--strict`: always; `--auto`: never). Otherwise continue.

Never start slice N+1 with slice N red.

## Phase 4 — QA

1. **/qa**: worker, `model: "opus"`. Preamble, then: *"Invoke /qa on this branch; it finds
   autoplan's test plan itself. Tier standard, or exhaustive if the change is user-facing or
   risky. Return pass/fail per test, every finding with severity and repro steps, and what you
   fixed."*
2. **UI changes**: follow the "After QA" section of `~/.loop/stages/design-context.md`.
   `/design-review` runs inline so its screenshots reach me.

## Phase 5 — Review

1. **/review**: worker, `model: "opus"`. Preamble, then: *"Invoke /review on this branch's diff.
   Return the full findings report and Codex's output, both verbatim."* Codex is the second
   model; don't summarise it away.
2. **/cso** if the change touches auth, data exposure, or untrusted input.
3. Final gate. Never ship red.

## Phase 6 — Visual sign-off (any user-visible change)

Show the final rendered result (design-review screenshots, or fresh ones via `/browse`) and
**stop for my approval**, even with `--auto`. On reject: `/design-shotgun evolve` from the
current screenshot, I pick, implement the delta, rerun the affected `/qa` (worker) and
`/design-review` (inline), and present again.

## Phase 7 — Ship

Invoke `/ship` inline (it runs `/document-release`). PR body: what changed and why, the ⚠
list, gate, QA and review results, and the artifact paths. **Never run `/land-and-deploy`**;
merging and deploying stay with me.

## Final output

Phase reached, artifact paths, consequential decisions, QA and gate results, and either the PR
link or the single blocking question.
