---
name: orchestrating-agents
description: >-
  Plan and verify parallel agents. Use before spawning children, briefing them,
  supervising shared-checkout work, or reporting their results.
license: AGPL-3.0-only
---

# orchestrating agents

children share files, CPU, mistakes. parent owns plan and verified result.
child says done? claim, not evidence. read diff, run tests yourself.

## plan

- dependency order first. build and verify shared API/test setup before fan-out.
- disjoint file owners. same file shared only with read-only readers. shared
  infrastructure gets one owner. roster in every brief; blockers go to owner.
- cap from machine capacity. build-heavy? three default, different toolchains
  where possible. serialize heavy suites; children use targeted tests first.
- select model and thinking level using the rules below. verify account can run it.
  stalled, hollow twice, asks permission for assigned work? replace within the
  user's model ceiling, not coach forever.
- fresh child `running=False`, no transcript? may still boot. end turn, wait
  for mail. no polling/sleep, no cancelling merely for that snapshot.

## model and thinking selection

- `await agents.models()` before spawning; use the live catalog, not remembered
  model names. choose explicitly. use the latest available version of the
  selected model or an eligible lower-tier member of its family.
- the user's model choice is a capability/cost ceiling, not permission to use
  every variant in the family. stay in that family at the same tier or lower;
  explicit user model/version constraints take precedence. ask before moving
  to a higher tier or another family, including when replacing a stalled child.
- examples: `6.1-sol` permits the latest Sol, Luna, or Terra. use a lower tier
  only when it can handle the task; Terra being eligible does not make it a
  useful default. `deepseek-4.1-flash` permits the latest Flash or a suitable
  lower tier, never Pro without user approval. version freshness does not
  override the tier ceiling. unclear family/tier relationship? keep the
  selected model rather than guessing an upgrade.
- prefer the lowest supported thinking level sufficient for the task. simple
  reading, extraction, or mechanical edits? use low, or off/none when offered.
  reserve higher thinking for complex reasoning, ambiguous design, or difficult
  debugging; do not default every child to the parent's thinking level.
- configure thinking through the supported spawn/session controls; check the
  available levels for the chosen model. do not invent parameters or levels.
  raise thinking within the allowed model only when task complexity or observed
  failures justify it; a harder task does not authorize a model-tier upgrade.

## brief

include:

- user's exact request and examples.
- skill/project docs to read first, especially touched subsystem docs.
- owned paths, sibling roster, exact shared names/fields/defaults.
- no commits unless authorized; no branch switch, stash, reset. unexpected work
  stays untouched. list forbidden heavy commands and compute budget.
- deliverables, required test commands, actual output, itemized changes.
  tests part of done. partial report only for named blocker, not "no time".
- report through `await mail.submit("parent", ...)`.

## verify and supervise

- read source/diff, not summary. count tests/assertions before/after ports.
  green after losing coverage is not done. inspect new files with status too.
- consequential claim? reproduce its evidence yourself. run full suite before
  reporting green. compare actual stored data before accepting deletion claims.
- missing deliverable? send exact list back once, then finish yourself.
- timeout increase, expectedFailure, blanket exclusivity, "may race"? demand
  mechanism, error, timing. fix product bug when evidence shows one.
- prove behavior through real program, including failure path. compile isn't enough.
- small cross-owner fix blocking child? do it, tell owner what changed.
- repeated template justifications? spot-check individual items.
- unowned failure may be in-flight sibling edit. route it; keep own files working.

## resources and scope

- tests use temp homes/config, never user's real data. services die with runner.
  close finished children. load complaint? inspect processes and measure first.
- commits name only owned paths. inspect status before/after; jj repo uses jj.
  unexplained deletion? ask, don't restore it. unexpected edits stay untouched.
- "show" doesn't mean publish. "push/merge" target unclear? ask. user merging?
  stop edits to that change; offer follow-up later.
- child's design must fit project rules. larger product behavior change? ask first.

report verified outcome, tests, wall time, remaining blockers. separate own
verification from child claims. product findings get separate note.
