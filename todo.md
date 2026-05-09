# Repo Migration Todo

## Root

- [x] .envrc
- [x] .gitignore
- [ ] .luarc.json
- [x] .sops.yaml
- [ ] AGENTS.md
- [x] LICENSE
- [ ] README.md
- [-] THIRD_PARTY_NOTICES.md
- [x] face.png (moved to assets/face.png)
- [-] flake.lock
- [-] flake.nix
- [x] vars.nix

## .github/

- [ ] dependabot.yml

## .github/workflows/

- [ ] ci.yml

## flake/

- [x] devshell.nix
- [ ] nixos.nix
- [x] treefmt.nix

## keys/users/

- [x] adam0.asc (moved to keys/)

## libs/

(moved to lib/)

- [-] attr-paths.nix
- [x] default.nix
- [x] env.nix
- [x] files.nix
- [x] mime.nix
- [x] starship.nix
- [x] stylix.nix

## modules/home/

- [ ] git.nix
- [ ] gpg.nix
- [ ] home.nix
- [x] sops.nix (moved to modules/nix/sops.nix)
- [ ] ssh.nix

## modules/home/cli/

(moved to modules/programs/cli)

- [ ] bat.nix (todo, fish shell pager export)
- [x] bonsai.nix
- [x] cpond.nix
- [x] direnv.nix
- [x] eza.nix
- [x] fd.nix
- [x] gh.nix
- [x] npm.nix
- [x] nys.nix
- [x] other.nix
- [x] pipes.nix
- [x] rumdl.nix
- [x] systeroid.nix
- [x] tlrc.nix
- [x] zoxide.nix

### New files

- [x] ripgrep.nix
- [x] bun.nix
- [x] speedtest.nix

## modules/home/cli/fastfetch/

(moved to modules/programs/cli)

- [x] default.nix
- [x] logo.png (moved to assets/nix.png)

## modules/home/cli/fish/

- [ ] abbreviations.nix
- [ ] aliases.nix
- [ ] default.nix
- [ ] plugins.nix

## modules/home/cli/fish/functions/

- [ ] fish_greeting.nix

## modules/home/cli/fish/functions/archive/

- [ ] 7z.nix
- [ ] rar.nix
- [ ] tar.nix
- [ ] un7z.nix
- [ ] unrar.nix
- [ ] untar.nix
- [ ] unzip.nix
- [ ] zip.nix

## modules/home/cli/ripgrep-all/

- [x] adapters.nix
- [x] default.nix

## modules/home/cli/ripgrep-all/adapters/

- [x] gron.nix
- [x] other.nix

## modules/home/cli/starship/

- [ ] build.nix
- [ ] container.nix
- [ ] default.nix
- [ ] disabled.nix
- [ ] format.nix
- [ ] general.nix
- [ ] git.nix
- [ ] languages.nix
- [ ] runtimes.nix

## modules/home/desktop/

- [ ] default.nix
- [ ] mangohud.nix
- [ ] overzicht.nix

## modules/home/desktop/hyprland/

- [ ] appearance.nix
- [ ] default.nix
- [ ] general.nix
- [ ] gestures.nix
- [ ] keybinds.nix
- [ ] monitors.nix
- [ ] plugins.nix
- [ ] rules.nix

## modules/home/desktop/noctalia/

- [ ] audio.nix
- [ ] bar.nix
- [ ] brightness.nix
- [ ] calendar.nix
- [ ] controlcenter.nix
- [ ] default.nix
- [ ] delobotomize.nix
- [ ] dock.nix
- [ ] general.nix
- [ ] hooks.nix
- [ ] idle.nix
- [ ] launcher.nix
- [ ] location.nix
- [ ] network.nix
- [ ] notifications.nix
- [ ] plugins.nix
- [ ] sessionmenu.nix
- [ ] systemmonitor.nix
- [ ] ui.nix
- [ ] wallpaper.nix

## modules/home/desktop/noctalia/patches/

- [ ] noctalia-launcher-ipc.patch
- [ ] noctalia-location-override.patch
- [ ] noctalia-settings-fallback.patch

## modules/home/desktop/stylix/

- [ ] default.nix
- [ ] delta.nix
- [ ] disabled.nix
- [ ] discord.nix
- [ ] eza.nix
- [ ] gtk.nix
- [ ] hyprcursor.nix
- [ ] noctalia.nix
- [ ] opencode.nix
- [ ] other.nix
- [ ] overzicht.nix
- [ ] spotify.nix
- [ ] television.nix

## modules/home/desktop/xdg/

- [ ] applications.nix
- [ ] autostart.nix
- [ ] cleanup.nix
- [ ] default.nix
- [ ] portal.nix
- [ ] terminal.nix

## modules/home/desktop/xdg/applications/

- [ ] audio.nix
- [ ] code.nix
- [ ] document-viewers.nix
- [ ] files.nix
- [ ] image-editors.nix
- [ ] image-viewers.nix
- [ ] protocols.nix
- [ ] video.nix

## modules/home/gui/

- [x] lutris.nix
- [x] onlyoffice.nix
- [x] other.nix (split into multiple files and modules for each application, and removed helium)
- [x] prism.nix
- [x] sober.nix
- [ ] spotify.nix (first need to figure out stylix)
- [x] zaread.nix
- [x] zathura.nix

## modules/home/gui/discord/

- [ ] default.nix

## modules/home/gui/discord/plugins/

- [ ] communication.nix
- [ ] core.nix
- [ ] integrations.nix
- [ ] interface.nix
- [ ] media.nix
- [ ] social.nix

## modules/home/gui/discord/themes/

- [ ] snippets.css
- [ ] system24.css

## modules/home/gui/ghostty/

- [ ] cursor.glsl
- [ ] default.nix
- [ ] keybinds.nix
- [ ] settings.nix

## modules/home/gui/zen/

(moved to modules/programs/gui/zen)

- [x] chrome.nix
- [x] default.nix
- [x] extensions.nix
- [x] mods.nix
- [x] policies.nix
- [x] preferences.nix
- [x] search.nix
- [x] spaces.nix

## modules/home/services/

- [x] flatpak.nix

## modules/home/tui/

(moved to modules/programs/tui)

- [ ] atuin.nix
- [ ] bluetui.nix
- [ ] btop.nix
- [ ] cava.nix
- [ ] fzf.nix
- [ ] impala.nix
- [ ] kmon.nix
- [ ] nvtop.nix
- [ ] other.nix
- [ ] oxicord.nix
- [ ] spotify-player.nix
- [ ] wiremix.nix (need to import terminal-exec before finished)

## modules/home/tui/neovim/

- [x] default.nix
- [x] keymap.nix
- [x] settings.nix
- [x] ui.nix

## modules/home/tui/neovim/components/

- [x] autocomplete.nix
- [x] biscuits.nix
- [x] breadcrumbs.nix
- [x] bufferline.nix
- [x] cheatsheet.nix
- [x] dashboard.nix
- [x] dim.nix
- [x] git.nix
- [x] hardtime.nix
- [x] highlight.nix
- [x] indent.nix
- [x] notify.nix
- [x] presence.nix
- [x] profiler.nix
- [x] scroll.nix
- [x] scrollbar.nix
- [x] session.nix
- [x] statusline.nix
- [x] telescope.nix
- [x] yazi.nix

## modules/home/tui/neovim/languages/

- [x] css.nix
- [x] default.nix
- [x] lua.nix
- [x] markdown.nix
- [x] nix.nix
- [x] other.nix
- [x] python.nix
- [x] rust.nix
- [x] toml.nix
- [x] typescript.nix

## modules/home/tui/opencode/

- [ ] default.nix
- [ ] env.nix
- [ ] formatter.nix
- [ ] instructions.md
- [ ] lsp.nix
- [ ] mcp-wrappers.nix
- [ ] plugins.nix
- [ ] settings.nix

## modules/home/tui/opencode/skills/

- [ ] create-readme.md
- [ ] default.nix
- [ ] find-skills.md
- [ ] nvf-config.md
- [ ] uncodixfy.md

## modules/home/tui/opencode/skills/lazy-mcp/

- [ ] context7.md
- [ ] github.md
- [ ] grep-app.md

## modules/home/tui/opencode/skills/nix/

- [ ] debug.md
- [ ] index.md
- [ ] search.md

## modules/home/tui/television/

- [ ] channels.nix
- [ ] default.nix
- [ ] nix-search.nix
- [ ] settings.nix

## modules/home/tui/television/channels/

- [ ] channels.nix
- [ ] files.nix
- [ ] man.nix
- [ ] text.nix
- [ ] tldr.nix
- [ ] trash.nix
- [ ] zoxide.nix

## modules/home/tui/yazi/

- [x] default.nix
- [x] init.lua
- [x] keymap.nix
- [x] plugins.nix
- [x] settings.nix
- [x] theme.nix

## modules/home/tui/yazi/plugins/

- [x] faster-piper.nix
- [x] mediainfo.nix
- [x] mount.nix
- [x] preview-cbz.nix
- [x] preview-epub.nix
- [x] preview-git.nix
- [x] recycle-bin.nix
- [x] relative-motions.nix
- [x] restore.nix
- [x] smart-enter.nix
- [x] smart-paste.nix
- [x] spot-audio.nix
- [x] spot-cbz.nix
- [x] spot-image.nix
- [x] spot-video.nix
- [x] tv.nix
- [x] ucp.nix

## modules/hosts/desktop/

- [ ] default.nix
- [ ] hardware.nix
- [ ] home.nix

## modules/hosts/laptop/

- [ ] default.nix
- [ ] hardware.nix
- [ ] home.nix

## modules/hosts/vm/

- [ ] default.nix
- [ ] hardware.nix
- [ ] home.nix

## modules/system/

- [ ] default.nix
- [ ] disk.nix
- [x] locale.nix (moved to modules/profiles/locale.nix)
- [ ] nix.nix
- [x] slim.nix (moved to modules/profiles/slim.nix)
- [x] sops.nix (moved to modules/nix/sops.nix)
- [x] tweaks.nix (moved to modules/profiles/tweaks.nix)
- [ ] user.nix

## modules/system/cli/

(moved to modules/programs/cli)

- [x] man.nix
- [x] nh.nix
- [x] other.nix (renamed to bandwhich.nix)
- [x] sudo-rs.nix

## modules/system/desktop/

(moved to modules/desktop)

- [ ] hyprland.nix
- [ ] stylix.nix
- [ ] tablet.nix
- [x] tuigreet.nix
- [ ] xdg-portal.nix

## modules/system/gui/

(moved to modules/programs/gui)

- [x] lsfg.nix
- [x] other.nix (split into services/printing.nix and gui/seahorse.nix)
- [x] steam.nix
- [x] virt-manager.nix

## modules/system/services/

(moved to modules/services)

- [x] ananicy.nix
- [x] avahi.nix
- [x] bluetooth.nix
- [x] geoclue.nix
- [x] gnome-keyring.nix
- [x] gvfs.nix
- [x] locate.nix
- [x] logind.nix (moved to modules/profiles/common/lidswitch.nix)
- [x] network.nix (split wifi up into sepperate wifi module)
- [x] other.nix (split up into multiple files)
- [x] pipewire.nix
- [x] podman.nix
- [x] printing.nix
- [x] scx.nix
- [-] ssh.nix
- [x] timesyncd.nix
- [ ] timezone.nix
- [x] tlp.nix
- [x] zram.nix

## overlays/

- [ ] _inputs.nix
- [ ] default.nix
- [ ] envfs.nix
- [ ] external-pkgs.nix
- [ ] hyprland-plugins.nix
- [ ] pkgs.nix
- [ ] superhtml.nix
- [-] zaread.nix

## pkgs/

- [ ] default.nix
- [x] lutris.nix
- [ ] nocheatsheet-nvim.nix
- [ ] telescope-all-recent-nvim.nix
- [x] zaread.nix

## pkgs/scripts/

- [ ] performant-mode.nix
- [x] systemd-status-preview.nix
- [ ] text-preview.nix

## pkgs/scripts/ripgrep-all-adapters/

(moved to modules/pkgs/ripgrep-all-adapters)

- [x] djvutorga-adapter.nix
- [x] pptx2md-adapter.nix

## secrets/

- [x] secrets.yaml
