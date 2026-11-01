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

- inspect `await commands.model()`, `await commands.effort()`, and
  `await agents.models()` before selecting children; recheck after a model switch.
  use live values and catalog IDs, provider-qualified when supported.
- stay on the parent's provider/account, including replacements. never change
  credentials or silently fall back elsewhere. provider identity alone does not
  prove account identity; unclear routing? keep the parent route or ask.
- default to the parent's exact model. choose an alternative only with evidence
  it can handle the task within the parent's capability/cost ceiling. no assumed
  families or tier hierarchy; names and newer versions are not evidence.
  explicit user model/version limits take precedence.
- ask before crossing provider/account boundaries or exceeding the ceiling.
  unclear eligibility? keep the parent's model; unavailable? ask.
- choose the lowest supported reasoning sufficient for the task, not the parent's
  effort by default. check levels for the chosen model and use documented controls;
  do not invent levels or parameters. harder work can justify more reasoning,
  not an unauthorized model upgrade.
- temporary, user-approved 2026-11-01, review after 2026-12-01: non-complex
  children may use `deepseek-v4.1-flash` on the user's opencode account even
  when the parent runs another family. it is near-free there, so cost beats
  family for this one model. simple reading, extraction, mechanical edits, and
  bounded changes with clear tests only, at low reasoning. not for complex
  reasoning, ambiguous design, hard debugging, or anything where a stall costs
  more than the saving. the catalog lists it bare, no `opencode/` prefix;
  confirm the live ID in `agents.models()` before spawning. task complex or
  model absent? parent model.

examples (subject to those limits):

- extract test names or rename a field: verified eligible cheaper model, low
  reasoning; off/none only if supported. no known suitable alternative? parent model.
- implement a bounded change with clear tests: parent model or verified eligible
  alternative, medium reasoning if supported.
- debug an intermittent race or review an ambiguous design: parent model, high
  reasoning if supported and needed.
- parent uses `provider-a/model-x`; catalog also offers `provider-b/model-x`:
  the latter needs approval despite the identical model name, unless it is the
  temporary `deepseek-v4.1-flash` exception above. `provider-a/model-y` needs no
  family relationship, but still needs suitability and ceiling evidence.

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
