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

# Library first

Own less code; solve the whole problem. Readable beats clever; fewer lines is
not the score. Think through choices; report the decision, not a ritual
checklist.

## Before code

Read touched code and project conventions. Trace callers, tests, fixtures,
exports, and config. Identify behavior, compatibility, data-loss, and security
risks. Fix the root cause at the shared seam and update every affected caller.
Skip unrelated cleanup.

## Reuse ladder

Take the first option that fully fits:

1. Not needed for the requested outcome: omit.
2. Project helper, component, service, or pattern: reuse as intended.
3. Standard library or platform feature: use it. House conventions still win.
4. Installed library solves it: use its documented API, not an imitation.
5. Substantial parsing, protocols, crypto, dates, validation, or infrastructure:
   look for a maintained library before building an engine.
6. No suitable fit: smallest clear implementation.

For a new dependency, verify current docs, maintenance, license, security,
runtime compatibility, and transitive cost. Compare integration cost against
code maintained here. A library earns its place by replacing meaningful
machinery; a few obvious lines do not need a package. If fit is uncertain, do a
bounded lookup, then decide; no package safari. Do not
invent APIs or assume the installed version supports one. Use the project's
dependency workflow and update the lockfile when needed.

## Keep small, not fragile

Skip speculative features, options, wrappers, layers, generic frameworks, and
"for later" code. Preserve the existing architecture. Delete obsolete code only
inside task scope. Expand a one-liner that needs decoding.

Keep trust-boundary validation, data-loss protection, error handling, security,
accessibility, and requested behavior; do not trade them away. When reusing or
moving code, keep these guarantees, because a library does not remove the
caller's responsibility.

For a known shortcut, state its limit and upgrade trigger near the code when
non-obvious. Comments explain why, not syntax.

## Prove and stop

Give non-trivial logic a focused regression test or executable self-check. Test
library integration and relevant edge cases, not library internals. Run scoped
tests plus configured formatting, lint, and typecheck; widen for shared changes.
If a check fails, fix the cause; do not weaken the check to pass.

Report the outcome and actual checks. State any material limit, risk,
or missing verification. Skip mandatory skipped-work footers, line-count scores,
and extra features.
