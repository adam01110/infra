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
allowed-tools: read grep find bash web_search fetch_content
---

# readme

Before creating or updating `README.md`, inspect the whole project and
workspace; do not assume.

Style, in priority order:

1. Local Adam style wins: structure, tone, formatting, detail.
2. Compare the primary references:
   <https://raw.githubusercontent.com/adam01110/nixos/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/adam01110/nur/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/adam01110/nix-userstyles/refs/heads/main/README.md>.
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
