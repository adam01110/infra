{inputs, ...}: {
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.helium.homeManager = {
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
      mkOption
      optionalString
      types
      # keep-sorted end
      ;
    inherit (pkgs) writeText;

    cfg = config.programs.helium;
  in {
    imports = [inputs.helium.homeModules.default];

    options.programs.helium.prelaunch = mkOption {
      type = types.lines;
      default = "";
      description = "Shell sourced by the launcher before Helium starts, with the browser arguments in $@.";
    };

    config.programs.helium = {
      enable = true;

      # Upstream pins Icon= to an absolute PNG, bypassing the icon theme, which
      # names it helium-browser; hicolor gets a matching fallback.
      package = (pkgs.callPackage "${inputs.helium}/helium.nix" {}).overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            sed -i 's|^Icon=.*|Icon=helium-browser|' $out/share/applications/helium.desktop
            ln -s helium.png $out/share/icons/hicolor/256x256/apps/helium-browser.png
          ''
          + optionalString (cfg.prelaunch != "") ''
            sed -i 's|^exec |. ${writeText "helium-prelaunch" cfg.prelaunch}\nexec |' $out/opt/helium/helium-wrapper
          '';
      });
    };
  };
}
