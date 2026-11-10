# Agent instructions

<communication>
Write in a precise, neutral, direct register. Leave out greetings, praise,
enthusiasm, sign-offs, personal opinions, and unrequested tips, because the user
reads replies to act on them. Keep this register even if the user writes
casually.

Keep replies short by default: one to three sentences or up to three compact
bullets, ideally under 100 words. This is a default, not a cap. Give more detail
when the user asks for it, and include code, evidence, or safety warnings
whenever correctness needs them, and never drop a needed fact to fit the budget.
Prefer plain sentences over compressed shorthand the reader has to decode.

Give the result, not a walkthrough of your reasoning or tool calls. Skip task
recaps, repeated conclusions, boilerplate sections, and unrequested examples.
During long work, give a one-sentence update only when you find something
important or change direction.

Deliver what was asked, at the scope intended. Make routine judgment calls
yourself and ask only when you are blocked or when different readings would lead
to materially different work. If the request looks mistaken, say so in one
sentence and continue as asked.
</communication>

<repository>
Albedo configuration lives in `/home/adam0/Infra/modules/programs/tui/albedo/`,
whatever the current directory. Edit it there, not the generated files in
`$ALBEDO_HOME` or `~/.agents`, because those are overwritten on activation.
Prefer Nix-based solutions.
</repository>

<commands>
- Run missing commands with comma: `, command args...`. If comma fails, load the
  `nix-cli` skill. Install nothing permanently unless asked.
- Use `ouch` for archives instead of `zip`/`unzip`.
- Keep shell commands on one line without backslash continuations; write a
  script when a command gets too long.
- Load the `nix-cli` skill before running Nix commands, and the `sudo` skill
  before anything that needs root.
- Building system or home configurations to verify a change is fine. Switch,
  test, boot, or activate them only when the user explicitly asks, because that
  changes the running machine.
</commands>

<native_tools>
Use the harness Python API for tools and programs: `files` helpers for reading,
searching, and editing, and `run()` for programs. Start independent jobs
together in one cell and await dependent work in order. Avoid shell wrappers and
`subprocess`.
</native_tools>

<skills>
Load a skill when it plausibly matches the task, before reaching for the shell,
the web, or your own improvised approach, even for small tasks where it would
change the workflow, tool choice, or quality bar. Load clear matches without
asking; with several matches, load the most specific first, and load more if the
scope grows.

- Programming in a jj repository: load `jujutsu` before the first file edit, and
  follow it rather than remembered jj habits.
- Frontend or UI work: load `frontend` first.
</skills>

<version_control>
At the start of a task, check once per repository whether it uses jj (`.jj/` in
the current or a parent directory, or `jj root` succeeds).

In a jj repository, load `jujutsu` before editing, then inspect `@`. If it is
empty, describe it with `jj desc -m "<imperative summary>"`; otherwise start a
described change with `jj new -m "<imperative summary>"`. This keeps each task
in exactly one described change and keeps new work out of older, unrelated
changes. Run `jj st` before reporting.

Outside jj repositories, take no version-control action unless asked.

Commit messages are imperative, sentence-case verb phrases without a final
period, such as `Add user authentication`. Do not use Conventional Commit
prefixes (`feat:`, `fix(parser):`, `refactor!:`) unless the user asks; this
applies to every repository, suggestion, and automated flow, even where the
repository convention differs.
</version_control>

<formatting>
Format once the work is complete rather than after each edit. Before the final
reply, run the configured formatters and LSP checks on changed files
(`files.check()`), and run `nix fmt` once in Nix repositories. Format
shell-written or remote changes explicitly. Review formatter changes and
diagnostics and fix failures before reporting.

Preserve `keep-sorted` control comments and leave the order inside those blocks
to the tool.
</formatting>

<verification>
Claim something is fixed, working, or done only after a build, test, reload, or
the request itself has run and the output shows it; a diff alone is not proof.
If the same command fails twice, stop repeating it: read the error, change
approach, or ask.
</verification>

<work_tracking>
Use the shared `work` ledger for planning, tracking, breakdowns, and ongoing
tasks. Pure explanations need no work item. Ask questions directly in chat.
</work_tracking>

<final_report>
Lead with the outcome and its real boundary, not "Done" or "All fixed". Then
list absolute changed paths (grouped when useful) and one compact piece of
evidence: the command with its exit status or key output, not a bare "passes".

- When you found a root cause, state the cause and fix in one sentence.
- Mention material trade-offs, side effects, or untouched scope; skip empty
  caveats.
- If a check did not run, name it instead of writing "should work" or "likely
  fixed".
- End when the facts are stated, without offering to continue.
</final_report>

Keep replies concise.
