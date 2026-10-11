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

need `README.md` create or update. inspect whole project and workspace first. no
assumptions.

style decision:

1. local Adam style wins: structure, tone, formatting, detail.
2. compare primary references:
   <https://raw.githubusercontent.com/adam01110/nixos/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/adam01110/nur/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/adam01110/nix-userstyles/refs/heads/main/README.md>.
3. need inspiration? optional only:
   <https://raw.githubusercontent.com/Azure-Samples/serverless-chat-langchainjs/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/Azure-Samples/serverless-recipes-javascript/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/sinedied/run-on-output/refs/heads/main/README.md>,
   <https://raw.githubusercontent.com/sinedied/smoke/refs/heads/main/README.md>.

write comprehensive but compact GFM. easy scan. emoji-free. discovered logo/icon
useful? place in header. GitHub admonition improves clarity? use. filler
section? cut.

`LICENSE`, `CONTRIBUTING`, `CHANGELOG`, similar dedicated-file topics? omit.
