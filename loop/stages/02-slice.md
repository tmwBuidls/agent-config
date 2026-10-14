# Stage 02 — Implement one slice

Build **exactly one slice** of the outline. Not the next one. Not a bit of the next one.

## Read first

1. The outline artifact (`*-outline-*.md`) — your slice, and the slices already done.
2. The design doc and research artifact it links, for anything ambiguous.
3. `CLAUDE.md` for repo conventions.
4. For UI slices, `~/.loop/stages/design-context.md` and the lead's established baseline,
   including product/design context paths and assumptions. Apply the installed Impeccable
   guidance to this slice's surface. If the baseline is absent, perform the proportionate
   local context check before implementing; return material unresolved conflicts to the lead.

## Scope

Your slice's **Demo**, **Files**, **Signatures**, **Test checkpoint** and **Done when** are the contract. The **Demo** is the one that matters: this slice is not done until that sentence is literally true in the running product.

Honor the outline's **Release value** where present: finish the coherent outcome, including necessary validation, error handling, and access controls, so it can ship without later slices. Wiring-only stubs are intermediate work, not completion. Larger slices do not authorize adjacent features or cleanup; report newly discovered work outside the contract instead of adding it.

**Older outlines** may have no **Demo** or **Layers touched** fields. Then derive the demo yourself from **Done when** + **Manual verification**, state it in your report as "Demo (derived)", and hold yourself to it the same way.

Slices are vertical, so yours will reach through several layers. Touching a file in a layer your slice needs is expected — the outline's **Layers touched**, where present, is your licence. What isn't allowed is widening: if you're editing a file that serves a *later* slice rather than this one, stop and say why in your report.

**Build only what this slice needs.** If a foundation is missing — a token, a config key, a helper, a table — add the minimum this slice consumes, not the general version. Later slices extend it. Generalising ahead of demand is how a vertical plan turns horizontal one slice at a time.

If the slice turns out to be wrong — a boundary that can't work, a signature that doesn't fit reality — **stop and report it**. Do not redesign around it. A bad boundary is cheap to fix in the outline and expensive to fix in five slices of code.

Follow the patterns the outline names. Match the surrounding code's idiom and naming. Don't introduce a new library, abstraction, or test framework — if the slice seems to need one, that's a report, not a decision.

## Code clarity and comments

Write code for someone who has never read the outline. Prefer descriptive names and straightforward control flow; don't add abstractions just to avoid a useful comment.

- Keep comments sparse. Explain non-obvious reasons, constraints, invariants, or workarounds that the code alone cannot convey. Don't narrate obvious operations or restate names and types in comments or docstrings.
- Keep task history and implementation sequencing in the outline, slice report, or `DECISIONS.md`. Do not put plan references such as "implemented in step 2", "slice 3", or "wire this up next phase" in source code or tests. Numbered explanations of an actual algorithm are fine when they help explain it.
- Describe a limitation in terms of current behavior and its reason. Future slice work belongs in the outline; add a TODO only for a concrete unresolved issue that needs to remain visible to maintainers, with an issue reference when available.
- Preserve useful existing explanations, required API documentation, license notices, and tool directives. Don't copy excessive comment density or clean up unrelated code.

## Tests

Write the slice's tests as you go, in the idiom the outline names. Tests assert the observable behaviour in **Done when**, not the shape of the implementation.

## Decisions

If you are a spawned subagent you cannot ask, so apply this unchanged. If you are running inline, still apply it — the point is that slice work proceeds on its own judgement and surfaces decisions in the report, rather than stopping the pipeline mid-slice.

- REVERSIBLE (changeable later with no migration, data loss, or broken published contract) → decide, append one line to `DECISIONS.md`, continue.
- LOAD-BEARING → pick your best option, proceed, and **return it in your report** with the reasoning and the alternative.
- Architectural or product-shaped → don't decide. Report it and let the outline be amended.

## Finish

1. Review the changed code for clarity. Remove task narration and redundant comments introduced by this slice; ensure remaining comments explain the code independently of the plan. Run the repo gate: typecheck, lint, the slice's tests. Fix what you broke.
2. **Prove the demo.** Actually run it and confirm the slice's Demo sentence is true — start the thing, hit the route, run the command. If you couldn't, say so explicitly in the report rather than implying it passed.
3. Do **not** commit — the router commits, so the slice lands as one reviewable unit.
4. Return the report below. Nothing else.

## Report

```markdown
## Slice N — [name] — [done | blocked]

**What works now**: [the end-to-end behaviour this slice added, in one line]
**Demo verified**: [yes — how I ran it and what I saw | no — why not]

**Files touched**
- `path/to/file.ts` — [what changed]

**Tests**: [what was added, and the result of running them]
**Gate**: typecheck [pass/fail] · lint [pass/fail] · tests [pass/fail]

**Manual verification**: [exact steps to see it work — commands, URLs, what to look for]

**UI context** (UI slices only): [baseline used, focused Impeccable work, relevant doc updates,
and any remaining assumptions or drift; distinguish rendered checks from source inspection]

**Load-bearing decisions**
- [Decision] — chose X over Y because [reason]. (none → say "none")

**Flags for the outline**
- [Anything that suggests a later slice's boundary is wrong. (none → say "none")]
```
