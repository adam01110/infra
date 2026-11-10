---
name: orchestrating-agents
description: >-
  Plan and verify parallel agents. Use before spawning children, briefing them,
  supervising shared-checkout work, or reporting their results.
license: AGPL-3.0-only
---

# Orchestrating agents

Children share files, CPU, and mistakes. The parent owns the plan and the
verified result. A child's "done" is a claim, not evidence: read the diff and
run tests yourself.

## Plan

- Order work by dependency. Build and verify shared API and test setup before
  fan-out.
- Give children disjoint files; share a file only with read-only readers. Shared
  infrastructure gets one owner. Put the roster in every brief; route blockers
  to the owner.
- Cap children by machine capacity: three by default for build-heavy work, on
  different toolchains where possible. Serialize heavy suites; children run
  targeted tests first.
- Select model and thinking level by the rules below; confirm the account can
  run it. Replace a child that stalls, reports hollow work twice, or asks
  permission for assigned work, within the user's model ceiling; do not coach
  it forever.
- A fresh child showing `running=False` with no transcript may still be booting.
  End your turn and wait for mail; do not poll, sleep, or cancel it over that
  snapshot.

## Model and thinking selection

- Inspect `await commands.model()`, `await commands.effort()`, and
  `await agents.models()` before selecting children; recheck after a model
  switch. Use live values and catalog IDs, provider-qualified when supported.
- Stay on the parent's provider and account, including for replacements. Do not
  change credentials or silently fall back elsewhere. Provider identity does not
  prove account identity; if routing is unclear, keep the parent route or ask.
- Default to the parent's exact model. Choose an alternative only with evidence
  it can handle the task within the parent's capability and cost ceiling. Do not
  assume families or a tier hierarchy; names and newer versions are not
  evidence. Explicit user model or version limits take precedence.
- Ask before crossing provider or account boundaries or exceeding the ceiling.
  If eligibility is unclear, keep the parent's model; if unavailable, ask.
- Choose the lowest sufficient reasoning level, not the parent's effort by
  default. Check the chosen model's levels and use documented controls; do not
  invent levels or parameters. Harder work can
  justify more reasoning, not an unauthorized model upgrade.
- Temporary exception, user-approved 2026-11-01, review after 2026-12-01:
  non-complex children may use `deepseek-v4.1-flash` on the user's opencode
  account even when the parent runs another family. It is near-free there, so
  cost beats family for this one model. Use it at low reasoning only for simple
  reading, extraction, mechanical edits, and bounded changes with clear tests;
  not for complex reasoning, ambiguous design, hard debugging, or anything where
  a stall costs more than the saving. The catalog
  lists it bare, without an `opencode/` prefix; confirm the live ID in
  `agents.models()` before spawning. Complex task or model absent? Use the
  parent model.

Examples, subject to those limits:

- Extract test names or rename a field: a verified eligible cheaper model, low
  reasoning; off/none only if supported. No known suitable alternative? Parent
  model.
- Implement a bounded change with clear tests: parent model or a verified
  eligible alternative, medium reasoning if supported.
- Debug an intermittent race or review an ambiguous design: parent model, high
  reasoning if supported and needed.
- Parent uses `provider-a/model-x`; catalog also offers `provider-b/model-x`:
  the latter needs approval despite the identical model name, unless it is the
  temporary `deepseek-v4.1-flash` exception above.
  `provider-a/model-y` needs no family relationship, but still needs suitability
  and ceiling evidence.

## Brief

Include:

- The user's exact request and examples.
- Skills and project docs to read first, especially touched subsystem docs.
- Owned paths, sibling roster, and exact shared names, fields, and defaults.
- No commits unless authorized; no branch switch, stash, or reset. Unexpected
  work stays untouched. List forbidden heavy commands and the compute budget.
- Deliverables, required test commands, actual output, and itemized changes.
  Tests are part of done. Partial reports only for a named blocker, not "no
  time".
- Report through `await mail.submit("parent", ...)`.

## Verify and supervise

- Read source and diff, not the summary. Count tests and assertions before
  and after ports, because green after losing coverage is not done. Check new
  files in status.
- Reproduce evidence for consequential claims yourself. Run the full suite
  before reporting green. Compare actual stored data before accepting deletion
  claims.
- If a deliverable is missing, send the exact list back once, then finish it
  yourself.
- For a timeout increase, expectedFailure, blanket exclusivity, or "may race",
  demand mechanism, error, and timing. Fix the product bug when evidence
  shows one.
- Prove behavior through the real program, including the failure path.
  Compiling is not enough.
- If a small cross-owner fix blocks a child, make it and tell the owner what changed.
- Spot-check individual items behind repeated template justifications.
- An unowned failure may be a sibling's in-flight edit. Route it; keep your own
  files working.

## Resources and scope

- Tests use temporary homes and config, never the user's real data. Services die
  with the runner. Close finished children. On a load complaint, inspect
  processes and measure first.
- Commits name only owned paths. Inspect status before and after; jj repos use
  jj. Ask about an unexplained deletion instead of restoring it. Unexpected edits
  stay untouched.
- "Show" does not mean publish. Ask if a "push" or "merge" target is unclear.
  If the user is merging, stop editing that change and offer a follow-up later.
- A child's design must fit project rules. Ask before a larger product behavior
  change.

Report the verified outcome, tests, wall time, and remaining blockers. Separate
your own verification from child claims. Product findings get a separate note.
