# Repo Migration Todo

Checklist of repository files grouped by path for the dendritic migration.

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

- [ ] devshell.nix
- [ ] nixos.nix
- [ ] treefmt.nix

## keys/users/

- [x] adam0.asc (moved to keys/)

## libs/

- [ ] attr-paths.nix
- [ ] default.nix
- [ ] env.nix
- [ ] files.nix
- [ ] mime.nix
- [ ] starship.nix
- [ ] stylix.nix

## modules/home/

- [ ] git.nix
- [ ] gpg.nix
- [ ] home.nix
- [x] sops.nix (moved to modules/nix/sops.nix)
- [ ] ssh.nix

## modules/home/cli/

(moved to modules/programs/cli)

- [x] bat.nix
- [x] bonsai.nix
- [x] cpond.nix
- [x] direnv.nix
- [x] eza.nix
- [x] fd.nix
- [x] gh.nix
- [ ] npm.nix (look at what to set in config)
- [x] nys.nix
- [ ] other.nix
- [x] pipes.nix
- [x] rumdl.nix
- [x] systeroid.nix
- [x] tlrc.nix
- [x] zoxide.nix

### New files

- [x] ripgrep.nix
- [ ] bun.nix (look at what to set in config)

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

- [ ] adapters.nix
- [ ] default.nix

## modules/home/cli/ripgrep-all/adapters/

- [ ] gron.nix
- [ ] other.nix

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

- [ ] lutris.nix
- [ ] onlyoffice.nix
- [ ] other.nix
- [ ] prism.nix
- [ ] sober.nix
- [ ] spotify.nix
- [ ] zaread.nix
- [ ] zathura.nix

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

- [ ] flatpak.nix

## modules/home/tui/

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
- [ ] wiremix.nix

## modules/home/tui/neovim/

- [ ] default.nix
- [ ] keymap.nix
- [ ] settings.nix
- [ ] ui.nix

## modules/home/tui/neovim/components/

- [ ] autocomplete.nix
- [ ] biscuits.nix
- [ ] breadcrumbs.nix
- [ ] bufferline.nix
- [ ] cheatsheet.nix
- [ ] dashboard.nix
- [ ] dim.nix
- [ ] git.nix
- [ ] hardtime.nix
- [ ] highlight.nix
- [ ] indent.nix
- [ ] notify.nix
- [ ] presence.nix
- [ ] profiler.nix
- [ ] scroll.nix
- [ ] scrollbar.nix
- [ ] session.nix
- [ ] statusline.nix
- [ ] telescope.nix
- [ ] yazi.nix

## modules/home/tui/neovim/languages/

- [ ] css.nix
- [ ] default.nix
- [ ] lua.nix
- [ ] markdown.nix
- [ ] nix.nix
- [ ] other.nix
- [ ] python.nix
- [ ] rust.nix
- [ ] toml.nix
- [ ] typescript.nix

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

- [ ] default.nix
- [ ] init.lua
- [ ] keymap.nix
- [ ] plugins.nix
- [ ] settings.nix
- [ ] theme.nix

## modules/home/tui/yazi/plugins/

- [ ] faster-piper.nix
- [ ] mediainfo.nix
- [ ] mount.nix
- [ ] preview-cbz.nix
- [ ] preview-epub.nix
- [ ] preview-git.nix
- [ ] recycle-bin.nix
- [ ] relative-motions.nix
- [ ] restore.nix
- [ ] smart-enter.nix
- [ ] smart-paste.nix
- [ ] spot-audio.nix
- [ ] spot-cbz.nix
- [ ] spot-image.nix
- [ ] spot-video.nix
- [ ] tv.nix
- [ ] ucp.nix

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
- [ ] locale.nix
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

- [ ] lsfg.nix
- [ ] other.nix
- [x] steam.nix
- [ ] virt-manager.nix

## modules/system/services/

(moved to modules/services)

- [x] ananicy.nix
- [x] avahi.nix
- [ ] bluetooth.nix
- [ ] geoclue.nix
- [x] gnome-keyring.nix
- [x] gvfs.nix
- [ ] locate.nix
- [ ] logind.nix
- [ ] network.nix
- [ ] other.nix
- [ ] pipewire.nix
- [ ] podman.nix
- [ ] printing.nix
- [ ] scx.nix
- [ ] ssh.nix
- [ ] timesyncd.nix
- [ ] timezone.nix
- [ ] tlp.nix
- [ ] zram.nix

## overlays/

- [ ] _inputs.nix
- [ ] default.nix
- [ ] envfs.nix
- [ ] external-pkgs.nix
- [ ] hyprland-plugins.nix
- [ ] pkgs.nix
- [ ] superhtml.nix
- [ ] zaread.nix

## pkgs/

- [ ] default.nix
- [ ] lutris.nix
- [ ] nocheatsheet-nvim.nix
- [ ] telescope-all-recent-nvim.nix
- [ ] zaread.nix

## pkgs/scripts/

- [ ] performant-mode.nix
- [ ] systemd-status-preview.nix
- [ ] text-preview.nix

## pkgs/scripts/ripgrep-all-adapters/

- [ ] djvutorga-adapter.nix
- [ ] pptx2md-adapter.nix

## secrets/

- [ ] secrets.yaml
