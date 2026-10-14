# UI design context

Read this when the work changes a user-visible interface: copy, interactions, states,
layout, or visual assets. Backend-only work skips it. Keep the effort proportional: a label
fix needs nearby context, a new surface needs a broader baseline.

## Establish the baseline (before the first UI worker)

Find the product and visual design context for the affected app: PRODUCT.md, a visual
DESIGN.md (not an architecture doc with that name), tokens, components, and representative
screens when runnable. Reuse research where it exists. Assess product and design separately
and record a short working baseline in the outline:

- **Current**: documents match the implementation and recent decisions. Reuse them as-is.
- **Greenfield**: draft the minimum context from the request (users, task, constraints,
  voice) and a modest visual direction. Label it provisional; invent no research or strategy.
- **Undocumented**: describe the patterns the code and screens actually use, separating
  observation from inferred intent. Don't redesign.
- **Stale or conflicting**: record the material discrepancies with evidence. An explicit
  user instruction or approved migration sets direction; consistent implementation is
  evidence, not approval. Don't enshrine bugs or one-offs as rules.

Missing or stale documents don't add a checkpoint. Make reversible choices, state
assumptions, and bundle any material unknowns into the outline checkpoint. If you couldn't
render the UI, say the baseline is source-derived.

## Building UI slices

Give the worker the baseline, document paths, and assumptions. For a new or restructured
surface, use the Impeccable skill's `shape` command before building. Explicit user choices
and the established design system beat generic aesthetic preferences.

## After QA

Run the design review step inline (gstack `/design-review`; it runs Impeccable's detector
when installed and suggests an `/impeccable <command>` for each deferred finding). Apply only
the suggestions that fall within the feature's scope, recheck what they touched, and keep
the final screenshots for visual sign-off.

## Docs

Update PRODUCT.md or DESIGN.md only for behavior or reusable rules this task actually
changed, with narrow, evidence-backed edits. Keep unconfirmed direction provisional until
its checkpoint settles it; leave unrelated historical drift recorded, not fixed.
