{inputs, ...}: {
  flake-file.inputs.overzicht = {
    url = "tarball+https://tangled.org/adam0.dev/overzicht/archive/main?format=tar.gz";
    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      import-tree.follows = "import-tree";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      # keep-sorted end
    };
  };

  flake.modules.homeManager.overzicht = {
    imports = [inputs.overzicht.homeModules.default];

    # Wait for UWSM to publish the Wayland session environment.
    systemd.user.services.overzicht.Unit.After = ["graphical-session.target"];

    programs.overzicht = {
      enable = true;
      systemd.enable = true;

      # Blend Overzicht's built-in panel shadow with a light fullscreen dim backdrop.
      settings.effects = {
        enableBackdrop = true;

        # keep-sorted start
        backdropOpacity = 0.18;
        emptyWorkspaceWallpaperOverlayOpacity = 0.12;
        panelOpacity = 0.93;
        windowOverlayOpacity = 0.06;
        workspaceOpacity = 1;
        # keep-sorted end
      };

      settings.appearance.rounding = {
        # keep-sorted start
        full = 0;
        large = 0;
        normal = 0;
        screenRounding = 0;
        small = 0;
        unsharpen = 0;
        verysmall = 0;
        windowRounding = 0;
        # keep-sorted end
      };
    };
  };
}
