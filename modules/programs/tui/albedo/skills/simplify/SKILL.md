---
name: simplify
description: >-
  Use only when the user explicitly invokes `/simplify` or explicitly asks to
  use the simplify skill; never use for ordinary implementation, review,
  cleanup, refactoring, or code changes.
license: AGPL-3.0-only
compatibility:
  Requires repository diffs; parallel subagent support is recommended.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Simplify settled changed code without behavior changes
argument-hint:
  "[blank to simplify current branch changes, or describe what to simplify]"
---

# Simplify

Use after implementation has settled, not while behavior is still changing.
Simplify is not a debugger; diagnose bugs separately first.

Goal: clarity, reuse, quality, efficiency, with exact behavior preserved.
Readable explicit code beats fewer lines.

## 1. Scope

Resolve in order:

1. A user-named scope is authoritative; do not widen it.
2. Otherwise, in a jj repo: the changes in `trunk()..@`, read with
   `jj --no-pager diff --from 'trunk()' --to @`.
3. Otherwise, in git: current branch versus base. No usable base? Staged and
   unstaged changes via `git diff HEAD`.
4. Outside version control or with no diff: user-named files or files edited
   earlier in the conversation.

If the scope is empty, ask in chat what to simplify, offering numbered
options, and wait for the answer rather than guessing.

Preflight: with no substantive human-authored code (only docs, generated/vendor,
dependencies/lockfiles, mechanical churn), report nothing to simplify and stop
before reviewers. Mixed scope keeps only code. The gate is kind, not size: an
explicit tiny scope still runs, because the caller owns the cost threshold.

Track review, apply, and verification as items in the `work` ledger, not one
item per reviewer.

## 2. Three reviews

Read these assets fully, then pass their full verbatim content plus the full
resolved diff/file set:

- `personas/code-reuse-reviewer.md`
- `personas/code-quality-reviewer.md`
- `personas/efficiency-reviewer.md`

Load the `orchestrating-agents` skill, then spawn one child per persona with
`agents.self.spawn`. If this session is itself a child (`agents.self.depth` is
1 or more) or spawning is unavailable, run the personas inline, one after
another.

Queue all three; launch only accepted concurrency. An active-agent or
concurrency limit is backpressure: keep the rest queued and spawn the next when
a child's mail arrives; do not poll or sleep. Other
dispatch failure? Run the same asset inline; disclose the substitution in one
line.

Choose the child model by the `orchestrating-agents` rules. A working inline
pass beats broken dispatch.

## 3. Decide and edit

Wait for all three outcomes. Apply worthwhile, proven findings. Skip false
positives and low-value ones without asking; record them.

Inspect outside scope if needed to judge. Edit only scope plus necessary
import/export seams; if the user named a file or directory, seams stay inside
it too. Skip a required edit that crosses this mutation boundary.

Preserve outputs, errors, side effects, and ordering. Cannot prove it? Skip.

A compat path existing only from an earlier unshipped iteration is removable
only after proving no deployed, persisted, public, external, dependent-branch,
or in-repo caller outside scope. Every caller update must fit
the mutation boundary; otherwise preserve it.

Do not thin or remove safety checks: trust-boundary validation, data-loss
protection, security checks, accessibility affordances.

A caller-supplied plan is context, not scope. Preserve decisions the plan or
the user settled, including deliberate duplication or separation.

## 4. Verify

Run project-wide typecheck and lint; as a child in a shared checkout, run them
on your own files only. Match tests to blast radius: scoped for
local, broader for shared/wide, full suite when the runner cannot scope.

On failure, report the check and relevant output. Caused by the simplification?
Fix or revert the responsible change. Do not weaken an assertion or
type, or skip a test.

No configured test, lint, or typecheck? Say so explicitly.

## 5. Report

Say what was already sound and what improved. Counts: reuse applied,
quality applied, efficiency applied, skipped. Include check outcomes. No
changes? Say
so. Net lines removed is not a success metric.
