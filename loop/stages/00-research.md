# Stage 00 — Research

Document the codebase **as it exists today**, so later stages design against reality instead of assumption.

## The one rule

**Your only job is to describe what exists.** Not what should exist.

- DO NOT suggest improvements, refactors, or optimisations.
- DO NOT critique the implementation or flag problems.
- DO NOT do root-cause analysis.
- DO NOT read the ticket, issue, or feature description. If it was passed to you, ignore it. Research must stay objective about the current system, not be steered by what someone wants to build. You were given research areas; that is enough.
- There is no "Implementation" section, and no "Recommendations" section. That is intentional.

Describe what exists, where it lives, how it works, and how the pieces connect.

## Steps

1. Read only what you need to **decompose the areas into questions** — entrypoints, module boundaries, and any file your areas name by path. Skim for structure here; do not read everything in full. The fan-out in step 3 does the full reads and step 4 verifies them, so reading everything at this level triples the input cost of the stage for no extra fidelity.
2. Decompose the areas into independent research questions. Think hard about the underlying patterns and connections, not just the surface. Track them in whatever task list your host provides.
3. Answer each question. **If your host supports subagents, spawn them in parallel — one per question** — giving each the question, the rule above, and an instruction to return `file:line` references for everything it claims. If it doesn't, work through the questions yourself in sequence.
4. Verify every claim against the code yourself before it goes in the document — a subagent's summary is not a source.
5. Establish how the system is run and observed — the run command, the entrypoints, where a change becomes visible. Verify by reading the scripts and route definitions, not by assuming the framework's defaults.
6. Capture provenance: `git rev-parse HEAD`, `git rev-parse --abbrev-ref HEAD`, repo name, ISO timestamp.
7. Write the artifact to the path you were given.
8. Return: the artifact path, a 5-line summary, and the Open Questions list.

## Template

```markdown
---
date: [ISO 8601 with timezone]
git_commit: [full hash]
branch: [branch]
repository: [repo name]
type: research
status: complete
---

# Research: [area]

## Scope
[The questions this document answers — one line each.]

## Methodology
This document is objective and factual. It contains no recommendations, no critique,
and no implementation suggestions. Open questions concern how the system works, never
whether it should work that way.

## Summary
[High-level: what exists, in prose. 5–10 lines.]

## Runtime & demo surface
[How this thing is run and observed today. Factual, like everything else here.]
- Run it: [exact command, and what it starts]
- Entrypoints: [URLs / routes / CLI commands a change would show up on — the real ones, cited]
- Observing a change: [where output appears — rendered page, log line, API response, terminal]
- Fixture / seed data: [what's needed for the above to show anything, if applicable]

## Detailed Findings

### [Component / area]
- What exists — `path/to/file.ts:123`
- How it connects to the rest of the system
- Current implementation details, stated without evaluation

#### Testing patterns
- How this component is tested today, with concrete examples
- Which layers exist: unit / integration / e2e / none

### [Next component]
...

## Code References
- `path/to/file.ts:123` — what's there
- `other/file.ts:45-67` — what that block does

## Patterns and Conventions
[Conventions actually in use in this codebase: error handling, state, naming, module
boundaries, test structure. Cite a file:line example for each.]

## Open Questions
[Gaps in understanding of the current system. "How does X work" — never "should Y be
the case". If there are none, say so.]
```

## Before returning

- Every factual claim carries a `file:line`.
- No sentence recommends, evaluates, or proposes.
- Testing patterns are covered — the outline stage depends on knowing how this codebase tests things.
- Runtime & demo surface is covered, concretely. The outline stage slices vertically, and a vertical slice is defined by where its result becomes visible. Without a real run command and real entrypoints, it can only slice by layer.
