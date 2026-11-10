---
name: sudo
description: >-
  Use when a command needs elevated (root) privileges, when sudo would be
  needed, or when an operation fails with a permission-denied error that only
  root can fix.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Elevate with run0 after user per-command approval
allowed-tools: bash
---

# sudo

Run elevated operations through `run0`, not `sudo`. `run0` raises a systemd
approval prompt where the user reviews each command's exact effect. Load this
skill only when a command needs root.

## Why run0

The user reviews the exact command request, not an agent-curated summary, and
root is granted per command rather than per session. This prevents an agent
from repeating `sudo` unattended.

## The message

Before each `run0` call, send the user a status message covering:

- why that command needs root
- what `run0` does when invoked
- what the approval prompt will ask of them

## Rules

- Send one message per command before running it, then wait for the approval
  flow to finish.
- Run elevated commands one at a time, with the full command text visible; do
  not hide it behind redirects, variables, or truncation.
- A denial is a blocked action, not an error. The rule to stop repeating a
  command that failed twice still applies to it.
- `run0` wraps a single command, not a script. Do not mark bun/npm/pnpm
  launchers as elevated.

## Flow

Request `sudo systemctl restart wpa_supplicant`:

1. Message: `run0 systemctl restart wpa_supplicant — needs root to restart
   the network daemon after removing stale state; run0 runs it as root via
   systemd and your approval prompt shows this exact command text.`
2. Run: `run0 systemctl restart wpa_supplicant`
3. The prompt appears on the user's side; the user reviews the command text and
   allows it.
4. If the user denies, report the result and stop without retrying.
5. If the user allows, the command runs as root; report the real output.
