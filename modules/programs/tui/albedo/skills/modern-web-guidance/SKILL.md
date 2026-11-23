---
name: modern-web-guidance
description: >-
  Google Chrome's guides to modern web platform features. Use before writing
  or changing client-side HTML, CSS, or JavaScript: dialogs, popovers, forms
  and autofill, accessibility, layout, view transitions and scroll-driven
  animation, dark mode, Core Web Vitals, security and passkeys, web
  components, and DOM work inside frameworks. Not for backend code,
  infrastructure, build tooling, tests, or trivial edits.
license: Apache-2.0
compatibility: Requires the modern-web-guidance CLI on PATH (Node.js 22 or later).
metadata:
  author: Google Chrome (modern-web-guidance), adapted by Adam0
  version: "1.0.2"
  short-description: Current web platform APIs, browser support and fallbacks
---

# Modern web guidance

Web platform APIs change faster than training data, so remembered patterns are
often superseded by a native feature or carry a known pitfall. This skill
provides about 200 short guides, one per capability, each giving the current
platform approach, browser support, fallbacks, and mistakes to avoid. Consult
them at the start of client-side work, before writing an ad hoc solution or
adding a dependency, and treat them as the project's standard unless the user
or project sets an explicit policy that differs. They cover platform APIs and
correctness; visual direction and copy belong to the `frontend` skill.

All commands below run the `modern-web-guidance` binary on PATH.

## Search, retrieve, verify

1. Search once per capability the task needs:

   ```sh
   modern-web-guidance search "light dismiss dialog"
   ```

   Use 2 to 5 English words naming one user-visible capability, usually a
   verb and a UI or platform object, plus the HTML, CSS, or JS feature name
   if you know it. Leave out framework, library, and app-specific names, and
   split multi-feature tasks into separate searches. When the request states
   an intent, search for the UI primitive it implies: "confirm dialog" rather
   than "confirm destructive action", "date picker input" rather than "pick a
   date". "Responsive data table" is a good query; "dialog" is too vague,
   "responsive table dark mode" needs two searches, and "close React settings
   modal on outside click" carries framework and app noise.

   The result is a JSON array of `{ "id", "description" }`; judge relevance by
   the descriptions. If one matches, retrieve it. If nothing fits, rephrase
   once with the concrete component noun or a synonym (dialog, modal, popover,
   table, form), then try `modern-web-guidance list` once; it prints every
   guide's ID and description as about 40 KB of JSON, so search or page it. If
   still nothing applies, continue without guidance rather than retrieving
   unrelated guides. A broad UI audit can start from `list`.

2. Retrieve the matching guides. When the task spans a whole discipline, or a
   specific guide points to one, also retrieve that broader guide (`html`,
   `css`, `js`, `forms`, `accessibility`, `color`, `performance`, `security`).
   Separate several IDs with commas:

   ```sh
   modern-web-guidance retrieve "light-dismiss-a-dialog,dialog"
   ```

   Take IDs only from `search` or `list` output, not from memory; after a
   context compaction, search again rather than reconstructing an ID. Output
   over about 9.5 KB goes to a temporary file whose path is printed; read that
   whole file. In a guide, "the `x` guide" means
   `modern-web-guidance retrieve x`.

3. Before finishing, check the code against the retrieved guides: the modern
   pattern is applied, the guide's fallbacks for the project's browser support
   are in place, and nothing unrequested was added just because a guide
   mentions it. Then confirm the result does what the user asked.

Guides for features in an Origin Trial or shipped in only one browser engine
are gated: `retrieve` prints a notice instead of that guide (other guides in
the same call still print, and the command exits 1) until the project opts in.
These features are experimental or single-engine, so adopting them is the
developer's decision: do not bypass the gate by running the opt-in command,
setting the opt-in keys in `.mwgrc`, or reading guide files from disk. If the
notice says the project has explicitly disabled the feature, do not use it;
build a standard cross-browser solution. Otherwise, use the gated feature
without the guide only if the user named that specific API, and tell them the
code is unverified against the guide and may be outdated; for a general goal,
build a standard cross-browser solution. In either case, tell the user which
guide was gated and that a developer can opt in by running the command the
notice names (`modern-web-guidance set-allow-origin-trials` or
`modern-web-guidance set-allow-volatile-features`) in their own terminal; it is
interactive and refuses to run from an agent.

## Adapting to frameworks

The guides use vanilla HTML, CSS, and JavaScript. Adapt them to the project's
framework without dropping the modern feature:

- Types: when the framework's type definitions lack a newly shipped attribute,
  pass it through a spread or cast rather than removing it or patching the
  type packages, for example
  `{...({ popover: 'hint', interestfor: id, commandfor: id, switch: '' } as any)}`
  in React, or `[attr.popover]` bindings in Angular.
- Server rendering and bundling: guard `window`, `HTMLElement`, and other
  browser globals during server rendering, and load polyfills with a bare
  `import('<package>')` in client-only code such as an effect. If a polyfill
  needs top-level `await`, raise the build target (Vite: `build.target:
  'esnext'`). Import from the package rather than copying files out of
  `node_modules`, which the bundler does not track and reinstalls replace.
- DOM, IDs, and CSS: call imperative APIs such as `showModal()` and
  `moveBefore()` through refs, on nodes the virtual DOM does not manage;
  generate IDs and `anchor-name` values per instance (React: `useId()`) so
  repeated components do not collide; keep `:root` rules and `@starting-style`
  at the top level, outside scoped or nested styles.

## Browser support and fallbacks

By default, Baseline Widely available features need no fallback. For anything
not yet Widely available, follow the guide's fallback recommendations unless
the user has set a different browser support policy, such as "no fallbacks",
"Safari 17.4 and later", "no polyfills; use a small custom fallback or
redesign", or "Newly available features are fine if feature-detected with
graceful degradation". Use the guide's compatibility data to apply such a
policy; for a "Baseline YYYY" target, a feature qualifies when its "Baseline
since" year is YYYY or earlier.

When the user asks, a project can record a Baseline target with
`modern-web-guidance set-baseline <widely|newly|limited|YYYY>`, which writes
`{ "baseline": ... }` to `.mwgrc`. Run it, and `retrieve`, from the project
root: both use the current directory or the nearest one above it that contains
`.mwgrc` or `.git`, else `~/.mwgrc` if it exists, else the current directory.
`retrieve` then opens each guide with a note on which fallbacks to omit. If
`.mwgrc` is not a valid JSON object, every `retrieve` fails with
`Invalid .mwgrc at <path>`. `.mwgrc` holds only that target and the opt-in
flags, so other constraints, such as excluded browsers or limits on polyfill
size, stay as instructions from the user.

## Modernizing an existing codebase

Use `legacy-scan` only for a broad, open-ended modernization or legacy-pattern
audit that names no specific feature or component. Work on a named feature or
component, including auditing one, uses the search workflow instead. The
scanner has deterministic rules for about a fifth of the guides, so a clean
scan does not mean the code is modern; say so when reporting.

1. Scan:

   ```sh
   modern-web-guidance legacy-scan <path> --json
   ```

   Docs, examples, demos, and tests are skipped unless you add
   `--include-docs-and-tests`; `--guide <id>` limits the scan to one guide.
   Each entry in `guides[]` has a `guideId` and `rules[]`; each rule has a
   `summary`, usually a `verifierRubric` with `keepWhen` and `dropWhen` lists,
   and `findings[]` with `file`, `line`, `message`, and `lineContent`.
2. Verify each finding against its rule's `keepWhen` and `dropWhen` criteria
   (or its summary and guide when there is no rubric), reading the code. Drop
   false positives: intentional fallbacks, helpers defined in another file,
   vendored code, and lookalikes.
3. Report the verified findings, with a modernization plan if you will edit.
4. If the user asked you to modernize rather than only report, retrieve each
   finding's guide, apply the replacement, and keep existing libraries as
   fallbacks where the guide calls for one. Re-run `legacy-scan <path> --json`
   on the scanned directory to confirm; it takes one path and ignores any
   others. Dropped findings and kept fallbacks still match the scan; leave that
   safe code alone rather than editing it, or reading the scanner's source, to
   reach zero findings.
