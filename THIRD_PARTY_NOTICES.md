<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Third-Party Notices

This repository is mixed-license.

Unless a file says otherwise, original repository code and configuration authored for this repository are intended to be licensed under `AGPL-3.0-or-later`.

Third-party and mixed-provenance files must keep their own attribution and license treatment.

## Derived From Nixpkgs

These files are derived from Nixpkgs package expressions and should continue to carry Nixpkgs attribution and MIT treatment.

| Path | Upstream | Treatment |
| --- | --- | --- |
| `pkgs/lutris.nix` | Nixpkgs `pkgs/applications/misc/lutris/fhsenv.nix` | Keep `Copyright (c) Nixpkgs contributors` and `SPDX-License-Identifier: MIT`. Do not relabel as solely AGPL. |
| `pkgs/zaread.nix` | Nixpkgs package expression for `zaread` | Keep `Copyright (c) Nixpkgs contributors` and `SPDX-License-Identifier: MIT`. Do not relabel as solely AGPL. |

Nixpkgs is distributed under the MIT license. The required MIT notice must remain with substantial copied or adapted material from Nixpkgs.

## Adapted From ripgrep-all Discussions

These files were adapted from code posted in GitHub Discussions associated with `phiresky/ripgrep-all`.

| Path | Provenance | Treatment |
| --- | --- | --- |
| `pkgs/scripts/ripgrep-all-adapters/djvutorga-adapter.nix` | `https://github.com/phiresky/ripgrep-all/discussions/166` | Keep provenance and adaptation notice. Do not assert a new SPDX identifier until the licensing basis for the discussion-posted code is confirmed. |
| `pkgs/scripts/ripgrep-all-adapters/pptx2md-adapter.nix` | `https://github.com/phiresky/ripgrep-all/discussions/199` | Keep provenance and adaptation notice. Do not assert a new SPDX identifier until the licensing basis for the discussion-posted code is confirmed. |

The `ripgrep-all` repository itself is `AGPL-3.0-or-later`, but these snippets were copied from discussion posts rather than from the main source tree. That is not a strong enough basis, by itself, to confidently relabel the adapted copies here as `AGPL-3.0-or-later`.

## Other Third-Party Material

| Path | Provenance | Treatment |
| --- | --- | --- |
| `modules/home/gui/discord/themes/system24.css` | `https://github.com/refact0r/system24` | Upstream repository is MIT-licensed. Preserve existing attribution block and keep MIT notice in mind when redistributing substantial copied copies. |
