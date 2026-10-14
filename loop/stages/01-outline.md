# Stage 01 — Structure outline

Turn the request and any approved design into **ordered vertical slices**, each independently demoable and shippable. A slice should deliver a coherent useful outcome that could be released even if later slices were deferred. This artifact becomes the plan file: `/autoplan` reviews it, `/review` measures coverage against it, `/ship` reports completion from it.

## Read first

1. The research artifact (`*-research-*.md`).
2. The request and, if present, the design doc (`*-{branch}-design-*.md`). A separate design doc is optional; if absent, capture the approach and necessary design decisions in this outline.
3. `CLAUDE.md` and `TODOS.md`.

**When present, link the design doc — do not restate it.** Current state, alternatives considered, and rationale already live there. Duplicating them creates two sources that drift, and the plan-review skills read both. Two pages, not ten.

## Scope budget

Hold the requested outcome fixed. Include work necessary for its correctness, safety, and usability; exclude adjacent features, speculative flexibility, and unrelated cleanup. Being nearby or cheap is insufficient justification. Any proposed expansion must identify a concrete failure in the requested outcome, explain why a narrower solution fails, and state its cost. Optional improvements stay out unless explicitly requested. Larger slices mean grouping related work within this scope, not adding more scope.

## Vertical, not horizontal

The default failure is a horizontal plan: all schema changes, then all service changes, then all API changes, then all UI. Nothing works until everything is done, so nothing can be verified early.

### The three tests

Every slice must pass all three, or it isn't a slice:

1. **Visible** — I can see the change in the running product. Name the URL, route, or command.
2. **Valuable** — it moves toward something a user wants, not toward architectural readiness.
3. **Full-depth** — it includes every layer needed for its own usable outcome, with real behavior and the validation, error handling, and access controls that outcome requires. It need not touch layers used only by later capabilities.

### Slice 1 is a complete core scenario

Deliver one useful core scenario end to end, including real persistence or integration where that scenario needs it. A hardcoded response that only proves wiring is an implementation checkpoint inside the slice, not a completed slice.

Work from the outside in: start at what the user can accomplish and include everything needed to ship that outcome.

### Never hoist

When several slices need the same foundation, build it **inside the first slice that needs it, sized to that slice alone**, and let later slices extend it. Pulling shared work forward into its own slice is the single most common way a vertical plan becomes horizontal. Duplication across slices is acceptable; a layer slice is not.

### Cut along behaviour, never along layers

Use a named axis for each cut, and say which one you used:

complete workflow · related CRUD operations · business-rule variation · data variation · simple-then-complex · optional advanced behavior

Keep related steps together when users need them for one outcome. Defer polish or advanced cases only when the earlier slice remains usable and safe; required auth, validation, and error handling belong with the behavior they protect.

For the first slice, use the meta-pattern: go straight at the core complexity, enumerate the variations, then collapse every variation to **one** complete scenario.

### Worked example — landing page with tokenised CSS

❌ Horizontal:
1. define the token scale → 2. wire tokens into CSS → 3. build the component library → 4. assemble the page

✅ Vertical:
1. visitors understand the offer at `/` and can follow the primary CTA: a responsive hero and feature section, with the typography, spacing, and tokens they need
2. visitors compare plans using real backend prices and can select a plan, with loading and failure states handled

### Sizing

A slice is right-sized when it delivers **one coherent, releasable outcome** and remains straightforward to review and verify. Prefer a few substantial slices over many tiny demonstrations:

- Merge slices that serve the same user outcome or would be awkward to release separately.
- A demo sentence may contain "and" when the behaviors form one coherent workflow.
- Split when outcomes are independently useful, risk needs isolation, or the change becomes difficult to review or verify.

There is no minimum slice count. One slice is valid; a bounded feature will often fit in 2–4. More slices need a concrete outcome or risk reason, never a quota. Do not combine unrelated outcomes merely to hit a target.

### Testing

Test each slice the way this codebase already tests that layer — the research artifact's "Testing patterns" section tells you how. Don't introduce a new test idiom here. Functional testing lives **inside** each slice, never as its own work item.

## Steps

1. Derive the slices within the scope budget. Start with the complete core scenario, then extend outward. Order them so each builds on the last and none needs a later one to be usable or verifiable.
2. Write each slice's **demo statement first** — one sentence describing a coherent user outcome. If it only proves wiring or an internal layer, re-cut before going further.
3. Then, for each: list every layer it touches, name the files, give real signatures and types for anything new or changed, state the test checkpoint.
4. Run the rejection list below over the whole plan. Re-cut anything it catches.
5. Sanity check: could I read this, disagree with a boundary, and move it — without reading any code? If not, it isn't specific enough.
6. Write the artifact to the path you were given.
7. Return the path, a **1–2 sentence overview of the rough implementation approach**, then the slice list as **name + demo statement**, one line each. The overview explains how the feature will work and which existing pieces it uses; do not turn it into a file inventory.

## Template

```markdown
---
type: structure-outline
branch: [branch]
sha: [git rev-parse HEAD]
design_doc: [path, or "none — see request"]
research_doc: [path]
---

# [Title]

[1–2 sentence overview of the rough implementation approach.]

## Desired end state
- [What is true when this is done — observable, not internal.]

## Not doing
- [Explicitly out of scope.]

## Patterns to follow
#### [Pattern name — from research]
[One line, plus the reference.] — `path/to/file.ts:88`
```[language]
[minimal example]
```

## Design decisions
Full rationale: [link to design doc if present; otherwise give brief rationale here]. Carried here, one line each:
- [Decision] → [what was chosen]

---

## Slice 1 — [a capability, phrased as observable behaviour]

**Demo**: [one sentence — the useful outcome I can demonstrate, and where: URL, route, or command]
**Layers touched**: [each layer needed to deliver this slice's outcome]
**Split axis**: [which behavioural axis produced this cut — "core scenario" for slice 1]
**Release value**: [why this is useful and safe to ship even if later slices are deferred]

**Files**
- `path/to/file.ts` — [what changes]

**Signatures**
```[language]
[new or changed signatures and types]
```

**Test checkpoint**: [the test that proves this slice, in this repo's existing idiom]
**Manual verification**: [exact steps to see it work]
**Done when**: [observable condition]

## Slice 2 — [a capability, phrased as observable behaviour]
...
```

## Rejection list

Reject and re-cut any slice whose name is a layer or a system rather than a capability. No exceptions:

> the token system · the design system · the component library · the API layer · the data model · state management · the schema · the service layer · scaffolding · setup · foundations

Also reject:
- A slice whose demo statement is about the codebase rather than the product ("the tokens are defined", "the endpoint exists").
- A slice that can't be thrown away. If deprioritising it wouldn't leave a smaller working product behind, it's a layer. This is the tiebreaker when two splits both look plausible: **choose the split that lets you throw a slice away.**
- A slice that needs a later slice to become useful or safe to release.
- A wiring-only or cosmetic fragment that belongs inside a larger coherent outcome.

## Before returning

- Every slice passes all three tests: visible, valuable, full-depth.
- Every slice has a one-sentence demo statement and a clear release value.
- Slice 1 delivers a complete core scenario through all the layers it needs.
- No foundation was hoisted into a slice of its own.
- Every slice names its split axis.
- Every slice is independently verifiable, shippable, and leaves the branch green.
- Scope stays within the requested outcome; slice count is justified by outcomes and risk.
- Signatures are real, not prose descriptions.
- The design doc, if present, is linked, not copied; otherwise necessary decisions are recorded here.
