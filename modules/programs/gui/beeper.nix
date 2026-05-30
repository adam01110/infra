{self, ...}: {
  flake.modules.homeManager.beeper = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    inherit
      (pkgs)
      # keep-sorted start
      makeDesktopItem
      writeShellScriptBin
      # keep-sorted end
      ;

    pkg = pkgs.nur.repos.forkprince.beeper-nightly;
    colors = config.lib.stylix.colors.withHashtag;
    rawColors = config.lib.stylix.colors;
    rgb = self.lib.self.stylixRgb rawColors;

    beeperAutostart = makeDesktopItem {
      name = "beeper-autostart";
      desktopName = "Beeper";
      icon = "beepertexts";
      startupWMClass = "Beeper";

      exec = getExe (writeShellScriptBin "beeper-autostart" ''
        sleep 4
        exec ${getExe' pkg "beeper"} --no-sandbox
      '');

      categories = [
        # keep-sorted start
        "Chat"
        "InstantMessaging"
        "Network"
        # keep-sorted end
      ];
    };
  in {
    imports = with self.modules.homeManager; [
      nur
      stylixPersonal
    ];

    home.packages = [pkg];

    xdg.configFile."BeeperTexts/custom.css".text = with colors; ''
      :root {
        color-scheme: dark;

        --color-bg: ${base00};
        --color-bg-rgb: ${rgb "base00"};
        --color-fg: ${base05};
        --color-fg-rgb: ${rgb "base05"};
        --color-primary: ${base0D};
        --color-primary-rgb: ${rgb "base0D"};
        --color-gray-rgb: ${rgb "base03"};

        --color-base-black: ${base01};
        --color-base-black-rgb: ${rgb "base01"};
        --color-base-white: ${base05};
        --color-base-white-rgb: ${rgb "base05"};

        --color-base-gray-10: ${base01};
        --color-base-gray-10-rgb: ${rgb "base01"};
        --color-base-gray-20: ${base01};
        --color-base-gray-20-rgb: ${rgb "base01"};
        --color-base-gray-30: ${base02};
        --color-base-gray-30-rgb: ${rgb "base02"};
        --color-base-gray-40: ${base02};
        --color-base-gray-40-rgb: ${rgb "base02"};
        --color-base-gray-50: ${base02};
        --color-base-gray-50-rgb: ${rgb "base02"};
        --color-base-gray-60: ${base03};
        --color-base-gray-60-rgb: ${rgb "base03"};
        --color-base-gray-70: ${base04};
        --color-base-gray-70-rgb: ${rgb "base04"};
        --color-base-gray-80: ${base04};
        --color-base-gray-80-rgb: ${rgb "base04"};
        --color-base-gray-85: ${base0D};
        --color-base-gray-85-rgb: ${rgb "base0D"};
        --color-base-gray-90: ${base06};
        --color-base-gray-90-rgb: ${rgb "base06"};
        --color-base-gray-100: ${base05};
        --color-base-gray-100-rgb: ${rgb "base05"};
        --color-base-gray-110: ${base04};
        --color-base-gray-110-rgb: ${rgb "base04"};
        --color-base-gray-120: ${base07};
        --color-base-gray-120-rgb: ${rgb "base07"};

        --color-dracula-red: ${base08};
        --color-dracula-orange: ${base09};
        --color-dracula-yellow: ${base0A};
        --color-dracula-green: ${base0B};
        --color-dracula-cyan: ${base0C};
        --color-dracula-purple: ${base0D};
        --color-dracula-pink: ${base0E};
        --color-dracula-comment: ${base03};

        --color-background-app: var(--color-bg);
        --color-background-app-weak: var(--color-base-gray-20);
        --color-background-elevated: var(--color-base-gray-30);
        --color-background-elevated-hover: var(--color-base-gray-50);
        --color-background-grouped: var(--color-base-gray-20);
        --color-background-grouped-weak: var(--color-base-gray-10);
        --color-background-object: var(--color-base-gray-30);

        --color-background-button-primary: var(--color-primary);
        --color-background-button-primary-active: var(--color-base-gray-85);
        --color-background-button-primary-disabled: var(--color-base-gray-60);
        --color-background-button-secondary: var(--color-base-gray-40);
        --color-background-button-secondary-active: var(--color-base-gray-50);
        --color-background-button-secondary-disabled: var(--color-base-gray-30);
        --color-background-button-translucent: rgba(var(--color-base-white-rgb), 0.1);
        --color-background-button-translucent-active: rgba(var(--color-base-white-rgb), 0.15);
        --color-background-button-translucent-disabled: rgba(var(--color-base-white-rgb), 0.05);

        --color-background-sidebar: rgba(var(--color-base-gray-30-rgb), 0.6);
        --color-background-sidebar-opaque: var(--color-base-gray-30);
        --color-background-sidebar-thread-focus: rgba(var(--color-base-white-rgb), 0.1);
        --color-background-sidebar-thread-selected: var(--color-background-selected-primary);
        --color-background-sidebar-thread-selected-unfocused: rgba(var(--color-base-white-rgb), 0.15);

        --color-background-message-active: var(--color-base-gray-20);
        --color-background-message-bubble-received: var(--color-base-gray-50);
        --color-background-message-bubble-sent: var(--color-primary);
        --color-background-message-bubble-linked: var(--color-base-gray-20);

        --color-background-selected-primary: var(--color-primary);
        --color-background-selected-secondary: rgba(var(--color-base-white-rgb), 0.1);

        --color-background-input: var(--color-base-gray-20);
        --color-background-kbd: rgba(var(--color-base-white-rgb), 0.15);
        --color-background-header-right: rgba(var(--color-base-gray-30-rgb), 0.9);
        --color-background-header-right-opaque: var(--color-base-gray-30);
        --color-background-menu: rgba(var(--color-base-gray-30-rgb), 0.9);
        --color-background-menu-opaque: var(--color-base-gray-30);
        --color-background-menu-option-hover: ${base0C};

        --color-border-neutrals: var(--color-base-gray-40);
        --color-border-neutrals-strong: var(--color-base-gray-50);
        --color-border-neutrals-weak: var(--color-base-gray-20);
        --color-border-input: var(--color-base-gray-40);
        --color-border-input-active: var(--color-base-gray-50);
        --color-border-translucent: rgba(var(--color-base-white-rgb), 0.1);
        --color-border-translucent-strong: rgba(var(--color-base-white-rgb), 0.15);
        --color-border-translucent-strongest: rgba(var(--color-base-white-rgb), 0.5);
        --color-border-translucent-weak: rgba(var(--color-base-white-rgb), 0.05);

        --color-text-neutrals: var(--color-fg);
        --color-text-neutrals-subtle: var(--color-base-gray-90);
        --color-text-neutrals-weak: var(--color-base-gray-110);
        --color-text-on-accent: ${base00};
        --color-text-on-accent-weak: rgba(${rgb "base00"}, 0.8);
        --color-text-translucent: rgba(var(--color-base-white-rgb), 0.9);
        --color-text-translucent-subtle: rgba(var(--color-base-white-rgb), 0.6);
        --color-text-translucent-weak: rgba(var(--color-base-white-rgb), 0.75);

        --color-icon-neutrals: var(--color-base-gray-90);
        --color-icon-neutrals-strong: var(--color-fg);
        --color-icon-neutrals-subtle: var(--color-base-gray-110);
        --color-icon-neutrals-weak: var(--color-base-gray-80);
        --color-icon-on-accent: rgba(${rgb "base00"}, 0.85);
        --color-icon-on-accent-strong: rgba(${rgb "base00"}, 0.95);
        --color-icon-on-accent-weak: rgba(${rgb "base00"}, 0.6);
        --color-icon-translucent: rgba(var(--color-base-white-rgb), 0.6);
        --color-icon-translucent-strong: rgba(var(--color-base-white-rgb), 0.9);
        --color-icon-translucent-subtle: rgba(var(--color-base-white-rgb), 0.3);
        --color-icon-translucent-weak: rgba(var(--color-base-white-rgb), 0.4);

        --color-background-scrollbar: rgba(var(--color-base-white-rgb), 0.3);
        --color-background-scrollbar-hover: rgba(var(--color-base-white-rgb), 0.5);
        --color-background-tag: rgba(var(--color-base-white-rgb), 0.1);
        --color-overlay-modal: rgba(0, 0, 0, 0.4);
        --color-transparent: rgba(0, 0, 0, 0);

        --left-pane-bg: transparent;
        --right-pane-bg: rgba(var(--color-bg-rgb), 1);
        --mark-bg: var(--color-base-gray-50);
        --error-color: ${base08};
        --warning-color: ${base09};
        --snoozed-indicator-bg: ${base09};
        --error-indicator-bg: var(--error-color);
        --message-snoozed-border: ${base09};
        --message-errored-beacon: var(--error-color);
        --sms-sent-bg: ${base0B};

        --compose-message-accent: var(--color-base-gray-90);
        --audio-bar-button: var(--color-base-gray-90);
        --audio-bar-preview-progress: var(--color-base-gray-120);
        --audio-bar-bg: var(--color-base-gray-20);
        --audio-bar-border: var(--color-base-gray-60);

        --key-border: var(--color-base-gray-40);
        --key-bg: linear-gradient(to bottom, var(--color-base-gray-40), var(--color-base-gray-20));
        --color-key-bottom-bg: var(--color-base-gray-20);
        --prefs-well: var(--color-base-gray-10);

        --ansi-black: ${base01};
        --ansi-red: ${base08};
        --ansi-green: ${base0B};
        --ansi-yellow: ${base0A};
        --ansi-blue: ${base0D};
        --ansi-magenta: ${base0E};
        --ansi-cyan: ${base0C};
        --ansi-white: ${base05};
        --ansi-bright-black: ${base03};
        --ansi-bright-red: ${base08};
        --ansi-bright-green: ${base0B};
        --ansi-bright-yellow: ${base0A};
        --ansi-bright-blue: ${base0D};
        --ansi-bright-magenta: ${base0E};
        --ansi-bright-cyan: ${base0C};
        --ansi-bright-white: ${base07};

        --functional-red: ${base08};
        --functional-orange: ${base09};
        --functional-green: ${base0B};
        --functional-cyan: ${base0C};
        --functional-purple: ${base0D};
        --focus-ring: var(--functional-purple);
        --link-color: var(--functional-cyan);
        --danger-bg: var(--functional-red);
        --success-bg: var(--functional-green);
        --warning-bg: var(--functional-orange);
      }

      .no-transparency,
      .reduce-transparency {
        --left-pane-bg: var(--color-background-sidebar-opaque);
        --color-background-header-right: var(--color-background-header-right-opaque);
        --color-background-menu: var(--color-background-menu-opaque);
      }
    '';

    xdg.autostart = {
      enable = true;
      entries = ["${beeperAutostart}/share/applications/beeper-autostart.desktop"];
    };
  };
}
