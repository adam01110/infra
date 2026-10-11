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
- `await agents.models()` before spawning; choose explicitly. cheap model for
  reading, strong model for implementation/judgment. verify account can run it.
  stalled, hollow twice, asks permission for assigned work? replace, not coach forever.
- fresh child `running=False`, no transcript? may still boot. end turn, wait
  for mail. no polling/sleep, no cancelling merely for that snapshot.

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
