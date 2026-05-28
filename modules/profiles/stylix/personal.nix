{self, ...}: let
  inherit (self.lib.self) stylixDisabledTargets;

  disabledHomeTargets = stylixDisabledTargets [
    # keep-sorted start
    "blender"
    "gnome"
    "kde"
    "nixcord"
    "obsidian"
    "vencord"
    "vesktop"
    # keep-sorted end
  ];
in {
  flake.modules.nixos.stylixPersonal = {pkgs, ...}: {
    key = "nixos-stylixPersonal";

    imports = with self.modules.nixos; [
      # keep-sorted start
      nur
      stylixBase
      # keep-sorted end
    ];

    stylix = {
      cursor = {
        name = "Bibata-Modern-Gruvbox-Dark";
        package = pkgs.nur.repos.adam0.bibata-modern-cursors-gruvbox-dark;
        size = 24;
      };

      icons = let
        name = "Gruvbox-Plus-Dark";
      in {
        enable = true;
        dark = name;
        light = name;
        package = pkgs.nur.repos.adam0.gruvbox-plus-icons;
      };

      # Use JetBrainsMono without ligatures.
      fonts = let
        inherit (pkgs.nerd-fonts) jetbrains-mono;
      in {
        # keep-sorted start block=yes newline_separated=yes
        monospace = {
          package = jetbrains-mono;
          name = "JetBrainsMonoNL Nerd Font Mono";
        };

        sansSerif = {
          package = jetbrains-mono;
          name = "JetBrainsMonoNL Nerd Font Propo";
        };

        serif = {
          package = jetbrains-mono;
          name = "JetBrainsMonoNL Nerd Font Propo";
        };
        # keep-sorted end
      };
    };

    fonts.packages = [pkgs.noto-fonts-cjk-sans];
  };

  flake.modules.homeManager.stylixPersonal = {
    key = "homeManager-stylixPersonal";

    imports = [self.modules.homeManager.stylixBase];

    stylix = {
      # keep-sorted start block=yes newline_separated=yes
      fonts.sizes = {
        # keep-sorted start
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 10;
        # keep-sorted end
      };

      opacity = {
        # keep-sorted start
        applications = 0.95;
        desktop = 0.95;
        popups = 0.95;
        terminal = 0.95;
        # keep-sorted end
      };

      targets = disabledHomeTargets;
      # keep-sorted end
    };
  };
}
