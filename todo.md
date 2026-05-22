# Repo Migration Todo

## Root

- [x] .envrc
- [x] .gitignore
- [-] .luarc.json
- [x] .sops.yaml
- [x] AGENTS.md
- [x] LICENSE
- [ ] README.md
- [-] THIRD_PARTY_NOTICES.md
- [x] face.png (moved to assets/face.png)
- [-] flake.lock
- [-] flake.nix
- [x] vars.nix

## .github/

- [-] dependabot.yml

## .github/workflows/

- [-] ci.yml

## flake/

- [x] devshell.nix
- [ ] nixos.nix
- [x] treefmt.nix

## keys/users/

- [x] adam0.asc

## libs/

(moved to lib/)

- [-] attr-paths.nix
- [x] default.nix
- [x] env.nix
- [-] files.nix
- [x] mime.nix
- [x] starship.nix
- [x] stylix.nix

## modules/home/

- [x] git.nix
- [x] gpg.nix
- [x] home.nix
- [x] sops.nix (moved to modules/nix/sops.nix)
- [x] ssh.nix

## modules/home/cli/

(moved to modules/programs/cli)

- [x] bat.nix
- [x] bonsai.nix
- [x] cpond.nix
- [x] direnv.nix
- [x] eza.nix (moved to eza/default.nix)
- [x] fd.nix
- [x] gh.nix
- [x] npm.nix
- [x] nys.nix
- [x] other.nix
- [x] pipes.nix
- [x] rumdl.nix
- [-] systeroid.nix
- [x] tlrc.nix
- [x] zoxide.nix

### New files

- [x] ripgrep.nix
- [x] bun.nix
- [x] speedtest.nix
- [x] eza/theme.nix
- [x] eh.nix
- [x] gitfetch.nix
- [x] nix-index.nix
- [x] onefetch.nix
- [x] ouch.nix
- [x] sshfs.nix

## modules/home/cli/fastfetch/

(moved to modules/programs/cli)

- [x] default.nix
- [x] logo.png (moved to assets/nix.png)

## modules/home/cli/fish/

(moved to modules/programs/cli/fish)

- [-] abbreviations.nix
- [x] aliases.nix
- [x] default.nix (removed fzfish)
- [x] plugins.nix (removed fzfish)

## modules/home/cli/fish/functions/

(moved to modules/programs/cli/fish)

- [x] fish_greeting.nix

## modules/home/cli/fish/functions/archive/

- [-] 7z.nix
- [-] rar.nix
- [-] tar.nix
- [-] un7z.nix
- [-] unrar.nix
- [-] untar.nix
- [-] unzip.nix
- [-] zip.nix

## modules/home/cli/ripgrep-all/

- [x] adapters.nix
- [x] default.nix

## modules/home/cli/ripgrep-all/adapters/

- [x] gron.nix
- [x] other.nix

## modules/home/cli/starship/

- [x] build.nix
- [x] container.nix
- [x] default.nix
- [x] disabled.nix
- [x] format.nix
- [x] general.nix
- [x] git.nix
- [x] languages.nix
- [x] runtimes.nix

## modules/home/desktop/

- [x] default.nix (moved into cliphist module)
- [x] mangohud.nix
- [x] overzicht.nix

### New files

- [x] cliphist.nix
- [x] uwsm.nix

## modules/home/desktop/hyprland/

- [x] appearance.nix
- [x] default.nix
- [x] general.nix
- [x] gestures.nix
- [x] keybinds.nix
- [-] monitors.nix
- [x] plugins.nix
- [x] rules.nix

## modules/home/desktop/noctalia/

- [x] audio.nix
- [x] bar.nix
- [x] brightness.nix
- [x] calendar.nix
- [x] controlcenter.nix
- [x] default.nix
- [x] delobotomize.nix
- [x] dock.nix
- [x] general.nix
- [x] hooks.nix
- [x] idle.nix
- [x] launcher.nix
- [x] location.nix
- [x] network.nix
- [x] notifications.nix
- [x] plugins.nix
- [x] sessionmenu.nix
- [x] systemmonitor.nix
- [x] ui.nix
- [x] wallpaper.nix

### New files

- [x] theme.nix

## modules/home/desktop/noctalia/patches/

- [x] noctalia-launcher-ipc.patch
- [x] noctalia-location-override.patch
- [x] noctalia-settings-fallback.patch

## modules/home/desktop/stylix/

- [x] default.nix
- [x] delta.nix
- [x] disabled.nix
- [x] discord.nix
- [x] eza.nix
- [x] gtk.nix
- [x] hyprcursor.nix
- [x] noctalia.nix
- [x] opencode.nix
- [x] other.nix
- [x] overzicht.nix
- [x] spotify.nix
- [x] television.nix

## modules/home/desktop/xdg/

- [x] applications.nix
- [x] autostart.nix (moved into the specific application modules)
- [x] cleanup.nix
- [x] default.nix (split into multiple files)
- [x] portal.nix
- [x] terminal.nix

### New files

- [x] dirs.nix
- [x] polkit.nix

## modules/home/desktop/xdg/applications/

- [x] audio.nix
- [x] code.nix
- [x] document-viewers.nix
- [x] files.nix
- [x] image-editors.nix
- [x] image-viewers.nix
- [x] protocols.nix
- [x] video.nix

## modules/home/gui/

- [x] lutris.nix
- [x] onlyoffice.nix
- [x] other.nix (split into multiple files and modules for each application, and removed helium, obsidian, krita)
- [x] prism.nix
- [x] sober.nix
- [x] spotify.nix
- [x] zaread.nix
- [x] zathura.nix

### New files

- [x] aseprite.nix
- [x] beeper.nix
- [x] bitwarden.nix
- [x] bleachbit.nix
- [x] crosspipe.nix
- [x] decibels.nix
- [x] flatseal.nix
- [x] gimp.nix
- [x] heroic.nix
- [x] loupe.nix
- [x] mcpelauncher.nix
- [x] proton.nix
- [x] showtime.nix
- [x] upscayl.nix
- [x] warehouse.nix

## modules/home/gui/discord/

- [x] default.nix
- [x] autostart.nix
- [x] settings.nix

## modules/home/gui/discord/plugins/

- [x] communication.nix
- [x] core.nix
- [x] integrations.nix
- [x] interface.nix
- [x] media.nix
- [x] social.nix

## modules/home/gui/discord/themes/

- [x] snippets.css
- [x] system24.css

### New files

- [x] default.nix

## modules/home/gui/ghostty/

- [-] cursor.glsl
- [x] default.nix
- [x] keybinds.nix
- [x] settings.nix

### patches/

- [x] cursor-tail-local-settings.patch

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

- [x] atuin.nix
- [x] bluetui.nix
- [x] btop.nix
- [x] cava.nix
- [x] fzf.nix
- [x] impala.nix
- [-] kmon.nix
- [x] nvtop.nix
- [x] other.nix (renamed to opencubicplayer.nix)
- [-] oxicord.nix
- [-] spotify-player.nix
- [x] wiremix.nix

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

### New files

- [x] docker.nix

## modules/home/tui/opencode/

- [x] default.nix
- [x] env.nix
- [x] formatter.nix
- [x] instructions.md
- [x] lsp.nix
- [x] mcp-wrappers.nix
- [x] plugins.nix
- [x] settings.nix

### New files

- [x] theme.nix

## modules/home/tui/opencode/skills/

- [x] create-readme.md
- [x] default.nix
- [x] find-skills.md
- [x] nvf-config.md
- [x] uncodixfy.md

## modules/home/tui/opencode/skills/lazy-mcp/

- [x] context7.md
- [x] github.md
- [x] grep-app.md

## modules/home/tui/opencode/skills/nix/

- [x] debug.md
- [x] index.md
- [x] search.md

## modules/home/tui/television/

- [x] channels.nix
- [x] default.nix
- [x] nix-search.nix
- [x] settings.nix

### New files

- [x] theme.nix

## modules/home/tui/television/channels/

- [x] channels.nix
- [x] files.nix
- [x] man.nix
- [x] text.nix
- [x] tldr.nix
- [x] trash.nix
- [x] zoxide.nix

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

- [x] default.nix
- [ ] disk.nix
- [x] locale.nix (moved to modules/profiles/locale.nix)
- [x] nix.nix
- [x] slim.nix (moved to modules/profiles/slim.nix)
- [x] sops.nix (moved to modules/nix/sops.nix)
- [x] tweaks.nix (moved to modules/profiles/tweaks.nix)
- [x] user.nix

## modules/system/cli/

(moved to modules/programs/cli)

- [x] man.nix
- [x] nh.nix
- [x] other.nix (renamed to bandwhich.nix)
- [x] sudo-rs.nix

## modules/system/desktop/

(moved to modules/desktop)

- [x] hyprland.nix (merged into hyprland/default.nix)
- [x] stylix.nix
- [ ] tablet.nix
- [x] tuigreet.nix
- [x] xdg-portal.nix

## modules/system/gui/

(moved to modules/programs/gui)

- [x] lsfg.nix
- [x] other.nix (split into services/printing.nix and gui/seahorse.nix)
- [x] steam.nix
- [x] virt-manager.nix

### New files

- [x] seahorse.nix

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
- [x] timezone.nix (moved to modules/profiles/common/timezone.nix)
- [x] tlp.nix
- [x] zram.nix

### New files

- [x] bpftune.nix
- [x] evolution-data-server.nix
- [x] libinput.nix
- [x] power-profiles-daemon.nix
- [x] udisks2.nix
- [x] upower.nix
- [x] wifi.nix

## overlays/

- [x] _inputs.nix
- [-] default.nix
- [x] envfs.nix (moved into the envfs module)
- [x] external-pkgs.nix
- [x] hyprland-plugins.nix
- [-] pkgs.nix
- [-] superhtml.nix
- [-] zaread.nix

## pkgs/

- [x] default.nix
- [x] lutris.nix
- [x] nocheatsheet-nvim.nix
- [x] telescope-all-recent-nvim.nix
- [x] zaread.nix

## pkgs/scripts/

- [x] performant-mode.nix
- [x] systemd-status-preview.nix
- [x] text-preview.nix

## pkgs/scripts/ripgrep-all-adapters/

(moved to modules/pkgs/ripgrep-all-adapters)

- [x] djvutorga-adapter.nix
- [x] pptx2md-adapter.nix

## modules/

- [x] capabilities.nix
- [x] shell-abbreviations.nix

## modules/nix/

- [x] dendritic.nix
- [x] determinate.nix
- [x] home-manager.nix
- [x] lib.nix
- [x] nur.nix
- [x] vars.nix

## modules/profiles/

- [x] personal.nix

## modules/pkgs/

- [x] os-age.nix

### preview/

- [x] man.nix
- [x] systemd-status.nix (moved from pkgs/scripts/systemd-status-preview.nix)
- [x] text.nix (moved from pkgs/scripts/text-preview.nix)

## secrets/

- [x] secrets.yaml
