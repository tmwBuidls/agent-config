# Scope contract — HOLD SCOPE

Every stage and every worker in the pipeline follows this, including nested reviewers.

Deliver the requested outcome completely, including the correctness, safety, and usability
work it needs. Larger slices group related work inside that boundary; they do not enlarge
the feature.

Expansion has a high bar. Name a concrete failure that stops the requested outcome from
working correctly, safely, or usefully; explain why a narrower fix cannot address it; and
record the smallest addition and its cost in the outline. Proximity, low effort, "while
we're here", future flexibility, or a higher completeness score are not reasons. Optional
features and unrelated cleanup stay out unless the user asks for them. Material product or
architecture changes go through the outline checkpoint.

This overrides plan-review defaults that pull the other way: SELECTIVE EXPANSION, "boil
lakes", and automatic approval of nearby work under a day. Interpret completeness within the
requested scope, and choose the simplest approach that satisfies it. When auto-choosing at a
gate, choose only options consistent with this contract. Skipping checkpoints never skips
this contract.
