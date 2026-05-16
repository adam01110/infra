{inputs, ...}: {
  flake-file.inputs.overzicht = {
    url = "github:adam01110/overzicht";
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
    };
  };
}
