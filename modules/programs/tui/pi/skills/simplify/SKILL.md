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
allowed-tools: read grep find bash Agent ask_user
argument-hint:
  "[blank to simplify current branch changes, or describe what to simplify]"
---

# simplify

activation gate: user invoked `/simplify` or explicitly asked for simplify
skill? continue. anything else—including ordinary code change, implementation,
review, cleanup, refactor—do not run.

bug diagnosis? use `ce-debug`; simplify is not debugger.

goal: clarity, reuse, quality, efficiency. exact behavior stays. readable
explicit code beats fewer lines.

## 1. scope

resolve in order:

1. user names scope? authoritative. never widen.
2. otherwise in git: current branch versus base. no usable base? staged +
   unstaged via `git diff HEAD`.
3. outside git/no diff: user-named files or files edited earlier in
   conversation.

empty scope? ask what to simplify. use blocking question tool: `AskUserQuestion`
in Claude Code (`ToolSearch` with `select:AskUserQuestion` first if schema
absent), `request_user_input` in Codex, `ask_question` in Antigravity CLI
(`agy`), `ask_user` in Pi with `pi-ask-user`. no blocking tool or call errors?
numbered chat options. schema load alone not failure. never silently skip
question.

preflight: substantive human-authored code absent—only docs, generated/vendor,
dependencies/lockfiles, mechanical churn? report nothing to simplify; stop
before reviewers. mixed? retain code only. kind gate, never size gate. explicit
tiny scope still runs; caller owns cost threshold.

task tracking available? show review, apply, verification outcomes. no
one-task-per-reviewer. unavailable? continue; no fake chat task list.

## 2. three reviews

read these assets fully, then pass full verbatim content plus full resolved
diff/file set:

- `personas/code-reuse-reviewer.md`
- `personas/code-quality-reviewer.md`
- `personas/efficiency-reviewer.md`

dispatch generic subagents through harness primitive (`Agent`/`Task` in Claude
Code, `spawn_agent` in Codex). no primitive? inline/serial.

queue all three. launch only accepted concurrency. active-agent/concurrency
limit means backpressure: keep queued, retry after slot frees. other dispatch
failure? run same asset inline; disclose substitution in one line.

model override exposed and known? balanced mid-tier. Claude Code: Sonnet. Codex:
only explicit model/custom-agent selector counts; wording cannot select model.
otherwise inherit parent. working parent pass beats broken dispatch.

omit dispatch `mode`; user permission config wins.

## 3. decide and edit

wait for all three outcomes. worthwhile and proven? apply. false positive/low
value? skip without asking; record.

inspect outside scope if needed to judge. edits limited to scope plus necessary
import/export seams. user named file/directory? seams also must stay inside it.
required edit crosses mutation boundary? skip.

preserve outputs, errors, side effects, ordering. cannot prove? skip.

compat path exists only from earlier unshipped iteration? removable only after
proving no deployed, persisted, public, external, dependent-branch, or in-repo
caller outside scope. every caller update must fit mutation boundary; otherwise
preserve.

safety check? never thin/remove. preserve trust-boundary validation, data-loss
protection, security checks, accessibility affordances.

caller supplied plan path with structure-pin? context, not scope. preserve
`session-settled:` Key Technical Decisions, including deliberate
duplication/separation.

## 4. verify

run project-wide typecheck and lint. tests match blast radius: scoped for local,
broader for shared/wide, full suite when runner cannot scope.

failure? report check and relevant output. caused by simplification? fix or
revert responsible change. never weaken assertion/type or skip test.

no configured test, lint, or typecheck? state explicitly.

## 5. report

say what was already sound and what improved. counts: reuse applied, quality
applied, efficiency applied, skipped. include check outcomes. no changes? say
so. net lines removed is not success metric.
