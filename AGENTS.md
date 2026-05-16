# Comment Style Guide

For `.nix` files only. Not for prose docs, copied upstream option descriptions, or commit messages.

## Rules

- Keep comments short, local, ASCII, and indented to the code they describe.
- Write sentence fragments in present tense and start with `#`.
- Prefer standalone comments above code, not trailing comments.
- Comment intent, rationale, constraints, non-obvious transformations, generated structure, or meaningful grouping.
- Skip comments for self-explanatory assignments, simple `inherit` blocks unless a subgroup needs a label, obvious enable flags, boilerplate module structure, and syntax boundaries like `let`, `in`, `{}`, `with`, or lambda heads.

## Placement

- Put comments directly above the smallest useful binding, attrset, list, or expression.
- Group comments directly above the grouped block.
- Comments inside lists or attrsets are fine when labeling a subsection.
- Do not put comments after `{ ... }:` or `_:` before `let`, or anywhere between a module or lambda head and `let`.
- Do not use comments as spacers above `let`.
- If a whole-block comment would otherwise go there, put it as the first meaningful line inside `in {`.

## Allowed Exceptions

- Preserve `keep-sorted` and similar tool-control comments.
- Rare TODOs may use `# TODO(<owner or reason>): ...`.
- Existing emphatic or humorous comments are fine if they still help readability.
- Upstream-style package headings or labels are fine when preserving imported structure helps.

## Review Standard

- Delete comments that only restate code.
- Move misplaced file or block comments below `in {` in `let`-using files.
- Keep comments attached to the exact code they explain.
- Preserve required control comments.
- Prefer deleting a weak comment over keeping noise.
