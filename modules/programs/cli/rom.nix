{self, ...}: {
  flake = {
    # Square off rom's rounded tree corners, both standalone and vendored in nh.
    overlays.rom = _final: prev: let
      squareCorners = dir: ''
        find ${dir} -type f \( -name '*.rs' -o -name '*.snap' \) \
          -exec sed -i 's/╭/┌/g; s/╮/┐/g; s/╰/└/g; s/╯/┘/g' {} +
      '';
    in {
      rom = prev.rom.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + squareCorners ".";
      });

      nh = prev.nh.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + squareCorners ''"$cargoDepsCopy"/source-registry-*/rom-*'';
      });
    };

    aspects.rom = {
      nixos.nixpkgs.overlays = [self.overlays.rom];

      homeManager = {pkgs, ...}: let
        tomlFormat = pkgs.formats.toml {};
      in {
        home.packages = [pkgs.rom];

        xdg.configFile."rom/config.toml".source = tomlFormat.generate "rom-config" {
          legend = "compact";
          log-prefix = "full";
          summary = "table";
        };
      };
    };
  };
}
