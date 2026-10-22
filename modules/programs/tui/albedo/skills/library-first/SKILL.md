---
name: library-first
description: >-
  Use before writing or changing code, when reviewing for unnecessary custom
  logic, or when choosing between existing helpers, platform APIs, and
  dependencies.
license: MIT
compatibility: Requires access to the target project and its toolchain.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Solve coding tasks with existing code and proven libraries
allowed-tools: read edit write grep find bash web_search fetch_content
---

# library first

less code to own. whole problem solved. readable beats clever; fewer lines not
score. think through choices; report decision, not ritual checklist.

## before code

read touched code and project conventions. trace callers, tests, fixtures,
exports, config. identify behavior, compatibility, data-loss and security risks.
fix root cause at shared seam; update every affected caller. no unrelated cleanup.

## reuse ladder

first option that fully fits:

1. not needed for requested outcome? omit.
2. project helper, component, service, pattern? reuse as intended.
3. standard library or platform feature? use it. house conventions still win.
4. installed library solves it? use documented API, not own imitation.
5. substantial parsing, protocols, crypto, dates, validation, or infrastructure?
   look for maintained library before building engine.
6. no suitable fit? smallest clear implementation.

new dependency? verify current docs, maintenance, license, security, runtime
compatibility, transitive cost. compare integration cost against code maintained
here. meaningful machinery replaced? library earns place. few obvious lines?
no package. uncertain fit? bounded lookup, then decide; no package safari.
never invent API or assume installed version supports it. use project dependency
workflow and update lockfile when needed.

## keep small, not fragile

no speculative features, options, wrappers, layers, generic framework, or
"for later" code. preserve existing architecture. delete obsolete code only
inside task scope. one-liner needs decoding? expand.

never trade away trust-boundary validation, data-loss protection, error
handling, security, accessibility, or requested behavior. reuse/move code?
keep these guarantees. library does not remove caller's responsibility.

known shortcut? state limit and upgrade trigger near code when non-obvious.
comments explain why, not syntax.

## prove and stop

non-trivial logic? focused regression test or executable self-check. test
library integration and relevant edge cases, not library internals. run scoped
tests plus configured formatting, lint, typecheck; widen for shared changes.
failed check? fix cause; never weaken check to pass.

report outcome and actual checks. material limit, risk, or missing verification?
state it. no mandatory skipped-work footer, line-count score, or extra features.
