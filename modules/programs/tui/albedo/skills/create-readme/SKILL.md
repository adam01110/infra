---
name: create-readme
description: >-
  Use when the user asks to create or substantially update a project README.md.
license: AGPL-3.0-only
compatibility: Requires repository filesystem access; web access is optional.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Create or update project README files
---

# readme

Before creating or updating `README.md`, inspect the project's structure, entry
points, configuration, and existing docs; do not assume.

Style, in priority order:

1. The project's existing README and docs win: structure, tone, formatting,
   detail.
2. Otherwise follow Adam's style in his own READMEs on Tangled:
   <https://tangled.org/did:plc:o4ij57xqkjq2bd26ecxe4qgp/raw/main/README.md>,
   <https://tangled.org/did:plc:n55a6vkyqulx4bf7x4ac4oss/raw/main/README.md>,
   <https://tangled.org/did:plc:zkwqzie5qsn4tqfkt4mvxqio/raw/main/README.md>,
   <https://tangled.org/did:plc:s2okz4xb2i7jtwk4sb35fofx/raw/main/README.md>,
   <https://tangled.org/did:plc:4yew6fq5qsishjxq7mizijnz/raw/main/README.md>.
3. Optional inspiration only:
   <https://raw.githubusercontent.com/Azure-Samples/serverless-chat-langchainjs/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/Azure-Samples/serverless-recipes-javascript/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/sinedied/run-on-output/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/sinedied/smoke/refs/heads/main/README.md>.

Write comprehensive, compact, scannable, emoji-free GFM. Put a discovered logo
or icon in the header when useful. Use GitHub admonitions where they add
clarity. Cut filler sections.

Omit dedicated-file topics such as `LICENSE`, `CONTRIBUTING`, and
`CHANGELOG`.
