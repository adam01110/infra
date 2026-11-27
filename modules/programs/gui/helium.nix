{inputs, ...}: {
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.helium.homeManager = {pkgs, ...}: {
    imports = [inputs.helium.homeModules.default];

    programs.helium = {
      enable = true;

      # Upstream pins Icon= to an absolute PNG, bypassing the icon theme, which
      # names it helium-browser; hicolor gets a matching fallback.
      package = (pkgs.callPackage "${inputs.helium}/helium.nix" {}).overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            sed -i 's|^Icon=.*|Icon=helium-browser|' $out/share/applications/helium.desktop
            ln -s helium.png $out/share/icons/hicolor/256x256/apps/helium-browser.png
          '';
      });
    };
  };
}
