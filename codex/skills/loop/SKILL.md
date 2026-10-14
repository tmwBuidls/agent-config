---
name: loop
description: |
  Research → optional design → shippable-slice outline → per-slice implement → QA → ship, through the
  gstack skills. Drives a feature from prompt to shipped PR, stopping on artifacts rather than
  on decisions. Use when asked to "loop this", "run the loop", "build this end to end", or
  given a feature description, spec file, or issue number to take all the way to a PR.
---

# loop — gstack pipeline, artifact-gated (Codex)

Drive a feature from prompt to shipped PR by invoking the **existing gstack skills**. Never
reimplement what gstack already does.

The interaction model: **stop on documents, not on decisions.** Reading a 200-line design doc
or a 2-page outline is cheap and high-leverage; being asked to adjudicate implementation
choices is not.

**The stage files are the source of truth**, shared with the Claude Code version of this
command. Read them from disk — do not paraphrase them from memory, and do not edit them to
suit a run:

- `~/.loop/stages/00-research.md`
- `~/.loop/stages/01-outline.md`
- `~/.loop/stages/02-slice.md`

## Model routing and host capabilities

The preferred lead model is **`gpt-6-astra`**. The local Codex CLI default selects it;
an explicit host or user model selection takes precedence. A skill cannot switch the live
lead model by declaring one in its text. When the active model is known to differ, report
that once and respect the user's selection. For a new CLI session use
`codex -m gpt-6-astra`; in Conductor select Astra in the model picker.

| Stage | Model | Reasoning effort |
|---|---|---|
| Lead, design, visual review, ship | `gpt-6-astra`, inline | Keep the session's selected effort |
| Research and its independent questions | `gpt-5.6-terra`, subagent | `medium` |
| Outline and autoplan | `gpt-6-astra`, separate subagents | `high` |
| Routine implementation slices | `gpt-5.6-sol`, subagent | `medium` |
| Complex slices or a failed worker's root-cause fix | `gpt-6-astra`, subagent | `high` |
| QA | `gpt-5.6-sol`, subagent | `high` |
| Adversarial review | `gpt-6-astra`, subagent, plus Claude outside review | `high` |

Use native subagents when the current host exposes them. This skill explicitly requests
delegation for these stages and parallel work for independent research questions. Keep
implementation slices sequential; never let two workers edit the same slice concurrently.

For every dispatch, specify the model and effort above using the tool's supported fields
(for example `model` and `reasoning_effort`); do not rely on inheritance. Use a fresh context
and pass only the task, artifact paths, relevant decisions, and required constraints. With
`collaboration.spawn_agent`, use `fork_turns: "none"` so model overrides are supported and
the lead's transcript is not copied. If another host's tool differs, follow its schema.
Apply the same explicit model policy to nested spawns: research questions use Terra,
routine helpers use Sol, and judgment-heavy plan/review work uses Astra.

Wait for a worker's completed result and verify its artifacts before advancing a dependent
phase. A spawn acknowledgement is not a result. Respect the host's concurrency limit;
use `run_in_background: false` only if that host's dispatch tool supports it.

Workers invoking gstack must set `GSTACK_SESSION_KIND=spawned` on the skill's preamble
and subsequent gstack shell commands. Include this in each dispatch prompt. Workers make
routine reversible decisions and report them; unresolved product/architecture choices and
approval requirements return to the lead. A worker cannot grant user approval or satisfy
an artifact or visual checkpoint. Return artifact paths, findings, auto-chosen decisions,
and verification evidence; relay outside-model findings verbatim.

If subagents or model overrides are unavailable, say which capability is missing once and
run the stage inline on the current model. Do not claim that routing or independent review
occurred. Keep large skill and browser transcripts in workers whenever possible. Summaries
do not remove prior turns from an inline context: persist artifacts for compaction or a
fresh-session `loop implement` resume instead of pretending to discard tokens.

Use the host's supported question mechanism for actual checkpoints; use prose and wait
when it is unavailable. User instructions and existing authorization take precedence over
skill defaults. Make routine decisions and continue between the defined checkpoints. If a
skill introduces an unexpected stop, identify the exact instruction and check whether it
applies before asking again. Run proportionate checks; broaden or repeat them only for
new changes, failures, or unresolved concerns.

## Flags

`--auto` (skip artifact and per-slice checkpoints; visual approval still applies) ·
`--strict` (stop after every slice) · `--oneshot` (skip to Phase 4) · `--design` /
`--no-design` (force Phase 2 on/off). If both `--auto` and `--strict` appear, the last wins.

**Stage re-entry:** if the request is exactly `research`, `design`, `outline`, or `implement`,
resume from that phase using the existing artifacts. Use this after editing an artifact by
hand, or after starting a fresh session.

## Artifacts

All stage output goes to `~/.gstack/projects/$SLUG/` so the gstack skills find it by glob.
Resolve once:

```bash
GSTACK_ROOT="$HOME/.codex/skills/gstack"
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$_ROOT" ] && [ -d "$_ROOT/.agents/skills/gstack" ] && GSTACK_ROOT="$_ROOT/.agents/skills/gstack"
eval "$($GSTACK_ROOT/bin/gstack-slug 2>/dev/null)"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/' '-')
DT=$(date +%Y%m%d-%H%M%S); U=$(whoami)
mkdir -p ~/.gstack/projects/$SLUG
```

`{U}-{BRANCH}-research-{DT}.md` · `*-{BRANCH}-design-*.md` (optional design note) ·
`{U}-{BRANCH}-outline-{DT}.md` (the plan file).

## Escalation contract

Classify each decision: **reversibility** (REVERSIBLE = changeable later with no migration,
data loss, or broken published contract; else LOAD-BEARING), and form a recommendation.

- REVERSIBLE → decide, log one line to `DECISIONS.md`, continue. Never ask.
- LOAD-BEARING + you have a recommendation → decide, apply, record under "⚠ Consequential
  decisions" for async veto. Don't stop.
- LOAD-BEARING + genuinely no winner (turns on product taste / business / cost / risk, not
  engineering) → **STOP and ask**, only in this form:
  > I'd choose **X** because <reasoning>. The case for **Y** is <reasoning>. This is a
  > <product / cost / risk> call I shouldn't make alone — which?

Never ask what you could answer. Never escalate without a recommendation. **Architecture and
product decisions are exempt** — don't auto-decide them mid-flight; write them into the current
artifact and let its checkpoint settle them.

**Visual override:** any user-visible change is ALWAYS rendered for sign-off before ship.
See Phase 7.

---

## Scope contract

**Default to HOLD SCOPE (`HOLD_SCOPE`) throughout the loop.** Deliver the requested outcome
completely, including necessary correctness, safety, and usability work. Larger slices group
related work inside that boundary; they do not enlarge the feature.

Expansion has a high bar: identify a concrete failure that prevents the requested outcome
from working correctly, safely, or usefully; explain why a narrower fix cannot address it;
and record the smallest addition and its cost in the outline. Proximity, low effort,
"while we're here", future flexibility, or a higher completeness score are insufficient.
Optional features and unrelated cleanup stay out unless the user explicitly requests them.
Material product or architecture changes go through the existing artifact checkpoint.

Pass this contract to outline, autoplan, implementation, QA, and review workers, including
nested reviewers. It overrides autoplan's SELECTIVE EXPANSION mode, "boil lakes" rule,
and automatic approval of nearby work under one day. Interpret completeness within the
requested scope; choose the simplest approach that satisfies it. Auto-choose only options
consistent with this contract. `--auto` skips checkpoints, not this scope constraint.
After autoplan, compare the revised outline with the requested scope and remove unjustified
additions before presenting it. Report any necessary additions and their justification.

## Phase 0 — Triage

Read the request and enough code to size it. Route:

- **Oneshot** (bugfix, copy change, single file, no new surface) → skip to Phase 4 with a
  one-slice outline. Say so in one line.
- **Full** (new surface, new dependency or data model, cross-cutting) → continue.

`--oneshot` / `--auto` override. Record the call; don't ask.

**UI context routing:** For user-visible interface changes, read
`~/.loop/stages/design-context.md` and follow it through implementation and verification.
Establish its proportionate product/design baseline before the first UI worker, including
on the oneshot path. Reuse research when running the full loop. Pass the baseline, context
paths, assumptions, and scope constraints to relevant outline, autoplan, UI, and review workers.
Missing or stale documents alone do not add a checkpoint; material decisions use existing ones.

## Phase 1 — Research

Dispatch a fresh **`gpt-5.6-terra` / `medium`** research worker to read
`~/.loop/stages/00-research.md` and follow it in full. Pass the research areas and resolved
artifact path, **not the ticket text or conversation history**. Have it pin any independent
question workers to **`gpt-5.6-terra` / `medium`**, within available capacity; otherwise it
answers them sequentially. Research describes the system as it is. On the inline fallback,
hold the request apart and document only what the code shows.

Always include **how the system is run and observed** as a research area, whatever else is in
scope. Phase 3 slices by where a change becomes visible; without that, it can only slice by
layer.

Carry research Open Questions into the design note when needed, otherwise into the outline.

## Phase 2 — Design note (only when needed)

Office hours is not part of the default loop. Use the request and research directly in the
outline when the outcome and approach are clear. A new UI surface, dependency, data model,
or cross-cutting change alone does not require a separate discovery exercise.

Write a short design note only when an unresolved product or architecture choice materially
affects the approach or slice boundaries, or when `--design` is set. Reuse an existing design
artifact only if it matches the current request. `--no-design` skips the separate note;
put necessary decisions into the outline checkpoint instead. Explicit `design` re-entry
requests this step.

The lead writes `{U}-{BRANCH}-design-{DT}.md` from the request and research: intended
outcome, scope/non-goals, recommended approach, material tradeoffs, and open questions.
Keep it brief and within the scope contract. Invoke **gstack-office-hours** only if the user explicitly
requests that discovery exercise, carrying the same scope constraints into it.

When a design note is written: **CHECKPOINT B — stop.** Give the path, a 1–2 sentence approach
summary, and unresolved material questions. Wait unless `--auto` or existing authorization
covers proceeding. When no note is needed, go directly to Phase 3.

Tell `gstack-autoplan` to skip any offer to run office-hours; missing a design doc is intentional.

## Phase 3 — Outline + review

Dispatch a fresh **`gpt-6-astra` / `high`** outline worker to read
`~/.loop/stages/01-outline.md` and follow it in full. Pass the request, scope contract,
research artifact path, optional design artifact path, and output path. Require coherent,
shippable outcomes with no minimum slice count. It returns ordered **vertical** slices in
the plan file.

**Verticality gate — before autoplan.** Re-read the outline and check every slice against the
stage file's three tests (visible · valuable · full-depth), release value, sizing guidance,
and rejection list. If any slice fails, re-cut it with the failures named. Don't hand a horizontal plan to review — the
reviewers will optimise it, not fix it.

Then dispatch a separate **`gpt-6-astra` / `high`** worker to invoke **`gstack-autoplan`**.
Include the spawned-session and scope contracts above. Explicitly require HOLD SCOPE
(`HOLD_SCOPE`), overriding SELECTIVE EXPANSION, boil-lakes, and cheap-nearby-expansion defaults
in every nested review. Preserve coherent, shippable slices with no minimum count. It returns
the test plan path, outline path, changes, findings, and auto-chosen decisions. Apply the
escalation contract to its report.
Tell it slice boundaries are **fixed as vertical**: it may reorder or resize slices, but
"build the foundation/token layer/API first" is out of scope. Tell it to skip any office-hours
offer. Respect gstack's guard against recursive Codex CLI reviews; a
fresh Astra worker alone does not provide a review from a different model family.

**CHECKPOINT C — stop.** Start with a **1–2 sentence overview of the rough implementation
approach**: how the feature will work and which existing pieces it uses. Then show the slice
list as **name + one-line demo statement**, followed by material review findings or justified
scope additions. Keep file inventories and detailed mechanics in the artifact. Use this
format whenever summarizing proposed or revised slices. Slice boundaries are the last cheap
thing to change. Wait.

## Phase 4 — Implement, one slice at a time

For each slice in order:

1. Dispatch a **`gpt-5.6-sol` / `medium`** worker to read `~/.loop/stages/02-slice.md`
   and follow it in full **for that slice only**. Use **`gpt-6-astra` / `high`** instead
   for slices requiring complex reasoning about concurrency, security, cross-cutting
   behavior, or ambiguous existing code. Pass the outline, supporting artifact paths,
   slice number, and relevant decisions. The shared code-clarity and comment rules apply.
   If a routine worker cannot resolve a failure, finish or stop it before handing its
   report and current diff to an Astra worker. Escalation does not reset the retry cap.
   For UI slices, include the established baseline and require the worker to read
   `~/.loop/stages/design-context.md`, apply the installed Impeccable guidance, and return
   relevant documentation updates and any unresolved context conflicts with its report.
2. Repo gate on that slice: typecheck, lint, tests. Fix and re-run; cap 3 attempts; if still
   red, stop and say exactly what's blocking.
3. Confirm the slice's **Demo** sentence is actually true — run it. A green gate on an unproven
   demo is the horizontal failure mode arriving late.
4. Commit the slice alone, with a message naming it.
5. **Report**: the demo statement and whether it's verified, what landed, files touched,
   decisions logged. Stop only when the slice has a load-bearing decision, flags an outline
   boundary as wrong, or touches a user-visible surface. Otherwise continue to the next slice.

`--auto` makes these per-slice stops report-and-continue; consequential decisions still go
in the report. `--strict` stops after every slice. Phase 7's visual approval remains required.

Never start slice N+1 with slice N red.

## Phase 5 — QA

Dispatch **`gpt-5.6-sol` / `high`** to run **`gstack-qa`** on the full branch using the
spawned-session contract. It discovers autoplan's test plan by glob. Standard tier;
**exhaustive** for anything user-facing or risky. Return pass/fail per test, findings with
severity and repro steps, fixes, evidence paths, and auto-chosen decisions. Escalate an
unresolved complex fix to **`gpt-6-astra` / `high`**, after the QA worker finishes.

For UI changes, apply the scoped Impeccable fixes and polish described in
`~/.loop/stages/design-context.md`; reuse existing findings and recheck affected behavior
after edits. Reconcile task-related product/design documentation for branch review.

Then **`gstack-design-review`** inline if there's a UI surface, so the lead can present its
before/after screenshots. Phase 7 reuses them. Any later UI edits require fresh affected
checks and screenshots before visual approval.

## Phase 6 — Adversarial review

1. Dispatch **`gpt-6-astra` / `high`** to invoke **`gstack-review`** on the branch diff
   using the spawned-session contract. Return the full findings report and verification
   evidence. Respect gstack's nested-Codex guard; do not force another Codex CLI pass to
   manufacture outside-model coverage.
   Obtain a bounded Claude outside review through **`gstack-claude` challenge mode**,
   adding `--model claude-fable-5-1 --effort high` to its tool-less CLI invocation.
   Keep `--disable-slash-commands --tools ""`; feed the diff and necessary context through
   a prompt file, never shell interpolation. Request findings with file/line, concrete
   failure scenario, and severity; keep the report concise. If gstack-review already
   returned an equivalent Claude outside review of the same diff, reuse it.
   Return Claude's findings verbatim and then reconcile them against the code. If Claude
   is unavailable or fails, disclose the missing coverage; do not call an Astra-only
   review cross-model. Apply the escalation contract to unresolved material findings.
2. **`gstack-cso`** — only if the change touches auth, data exposure, or untrusted input.
3. Final repo gate. Never ship red.

## Phase 7 — Visual sign-off (design changes only) — MANDATORY

If there's any user-visible surface:

- Present the rendered result — design-review screenshots, or fresh ones via `gstack-browse`.
- **STOP for approval.** Don't ship on your own judgement here even if everything passed.
- **On reject:** `gstack-design-shotgun evolve` from the current screenshot, I pick, implement
  the delta, re-run the relevant QA + design-review, present again. Loop until approved.

## Phase 8 — Ship

Invoke **`gstack-ship`** (sync-main → test → push → open PR; auto-runs document-release). PR
summary: what changed, why, the ⚠ list, gate + QA results, and links to the artifacts produced (design note only if present).

**Do not run `gstack-land-and-deploy`.** Merge and deploy stay with me.

## Final output

Short status only: phase reached, artifact paths, consequential decisions, QA/gate results, and
either the PR link or the single blocking question.
