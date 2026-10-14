# UI design context and Impeccable

Read this when a loop changes a user-visible interface, including copy, interactions,
states, layout, or visual assets. Backend-only work skips it. Keep the effort proportional:
a label fix needs nearby context, while a new surface needs a broader baseline.

## Establish the baseline

Before UI planning decisions or the first UI worker, inspect the request, existing product/design documents and
their linked decisions, relevant tokens/components, and representative affected screens
when runnable. Reuse Phase 1 research; a oneshot performs only the local check it needs.
Search for equivalent context before assuming root PRODUCT.md or DESIGN.md is missing.
In a monorepo, use the affected app's context and retain links to shared design systems.
Do not confuse an architecture document named DESIGN.md with a visual design system.

Assess PRODUCT and DESIGN separately: either may be missing or stale while the other is
useful. Record evidence and a working baseline in the existing design note or outline
(a short entry in a oneshot outline is enough). Classify the affected context:

- **Current:** documents agree with explicit decisions and the relevant implementation.
  Reuse them; don't rewrite them as an onboarding ritual.
- **Greenfield:** no established implementation or direction exists. Draft the minimum
  product context from the request and known facts: intended users, task/outcome, operating
  context, constraints, and voice where known. Label assumptions. Propose a modest visual
  direction appropriate to that context; mark it provisional until reviewed. Do not invent
  customer research, business strategy, approved references, or implemented tokens.
- **Existing but undocumented:** reconstruct observed flows and the reusable visual system
  from representative screens, source, tests, and decisions. Separate observations from
  inferred intent. Code can show what the product does; it cannot prove who needs it or why.
  Document the established patterns and remaining unknowns without redesigning the app.
- **Stale or conflicting:** compare the relevant document claims with the implementation
  and recent decisions/history. Record the material discrepancies and their evidence.
  An explicit user instruction or approved migration establishes intended direction.
  Widespread consistent implementation is evidence for a working baseline, not proof of
  approval. Preserve a coherent surrounding pattern for local reversible work; do not
  enshrine isolated bugs, accessibility failures, or inconsistent one-offs as design rules.
  If a document is aspirational, retain that distinction from current implementation.

Document age alone does not prove staleness. If rendering is unavailable, label the baseline
as source-derived and carry visual verification forward; do not claim screenshots were checked.

## Resolve gaps without unnecessary stops

Missing files and routine documentation drift do not require a new interview or checkpoint.
Use the request and existing evidence, make reversible choices, and state assumptions.
Ask only about a material unknown that changes the requested outcome or a consequential
direction with no supported recommendation. Bundle those gaps into the existing design/outline
checkpoint; continue independent work. Existing authorization and the loop's escalation,
scope, and visual approval contracts take precedence over Impeccable's setup defaults.
The user's loop policy authorizes narrow, evidence-backed context maintenance for the
affected work, including reconciliation of stale claims. This overrides blanket skill
defaults against doc updates or requiring permission for routine refreshes; it does not
authorize unrelated artifact/schema migrations, invented product intent, or a redesign.
`--no-design` skips the separate note, not this context check. `--oneshot` and `--auto` still
establish a proportionate baseline; they do not turn guesses into approved product facts.

Create or patch PRODUCT.md / visual DESIGN.md only as needed for this task. Prefer narrow
updates with evidence over wholesale regeneration; preserve useful decisions and unrelated
sections. When context lives elsewhere, use concise pointers/compatible summaries rather
than competing specifications. Do not overwrite an architecture DESIGN.md to satisfy a tool.
If the skill cannot consume the established layout, pass the context explicitly and disclose
the limitation. Keep unconfirmed direction provisional in the plan until its checkpoint is
settled; don't publish it as established truth in durable docs.

## Apply Impeccable within the loop

Discover the installed skill for the active host and read its SKILL.md before invoking it.
Claude commonly uses ~/.claude/skills/impeccable; Codex uses .agents/skills/impeccable in
the project or ~/.agents/skills/impeccable (also check ~/.codex/skills/impeccable). Resolve
helper/reference paths against the actual installation, not a hard-coded project folder.
Run context helpers from the affected app, or pass the task's known target path when
supported. Resolve obvious monorepo targets from the request instead of asking again.
If unavailable, report the missing coverage and continue the existing design workflow;
do not install or update tools silently during a feature run.

Use the installed version's vocabulary: setup may be `init` or `teach`. Reuse established
context to satisfy setup instead of repeating its interview. `document` can aid extraction
when documentation is missing/stale, but its output is a draft to reconcile with the evidence
above, not permission to rewrite the product. A seeded greenfield design is provisional.

For UI implementation, pass the worker the baseline, document paths, assumptions, and relevant
constraints. Apply the installed version's surface guidance (such as product/brand or
Operate/Persuade/Read/Experience) to the actual surface. Explicit user
choices and the established design system override generic aesthetic preferences.
Choose focused commands by need: `shape` for unresolved UI structure before implementation,
`clarify` for copy, `harden` for UI edge states, `adapt` for resizing, and `layout` / `typeset`
for corresponding visual problems. Do not run every command or broaden the feature.

In Phase 5, use QA/design findings to select scoped fixes and a proportionate `polish` pass
on the changed surface. Reuse gstack's Impeccable detector findings when available; verify
them in context rather than repeating an equivalent audit. Reserve a separate `critique`
or `audit` for a concrete gap in the existing review. Run final inline design-review after
these edits so its screenshots show the final result. Recheck affected behavior after fixes.

Keep durable context in step with the implemented outcome: update only product behavior or
reusable design rules actually changed by the task, replacing provisional entries with
verified facts as appropriate. Routine UI edits need no documentation churn. Include relevant
doc changes in the branch review; after visual approval, reconcile any remaining provisional
visual direction before ship. Unresolved historical drift outside the task stays recorded
as such rather than becoming a surprise redesign. Later UI edits invalidate the affected
screenshots and checks; rerender and follow the existing visual sign-off contract.
