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

`sudo` is not for elevated operations. Elevated work goes through `run0`.
`run0` generates a systemd approval prompt for the user to review each
command's exact effect. Load this skill only when a command needs root.

## why run0

`run0` sends a message to the human to review each command's exact request,
not an agent-curated summary. Root access is granted per command, not per
session. An agent repeating `sudo` unattended is the failure mode this blocks
before it starts.

## the message

Before each `run0` call, send the user a status message covering:

- why that command needs root
- what `run0` does when invoked
- what the approval prompt will ask of them

## rules

- one message per command, sent before running it, then wait for the
  approval flow to finish.
- never queue elevated commands or hide command text via redirects,
  variables, or truncation.
- a denial is not an error — it is a blocked action, not an exception to
  "same command fails twice? stop repeating it".
- `run0` wraps a single command, not a script. no bun/npm/pnpm launchers
  marked elevated.

## flow

Request `sudo systemctl restart wpa_supplicant`:

1. message: `run0 systemctl restart wpa_supplicant — needs root to restart
   the network daemon after removing stale state; run0 runs it as root via
   systemd and your approval prompt shows this exact command text.`
2. run: `run0 systemctl restart wpa_supplicant`
3. prompt appears on the user's side, user reviews command text, allows.
4. if user denies: report result and stop, no retry.
5. if user allows: command runs as root, report the real output.
