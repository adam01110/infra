{self, ...}: {
  flake.modules.homeManager.zfetch = {pkgs, ...}: let
    inherit (pkgs.nur.repos.adam0) zfetch-rs;

    tomlFormat = pkgs.formats.toml {};
  in {
    imports = [self.modules.homeManager.nur];

    home.packages = [zfetch-rs];

    xdg.configFile."zfetch/config.toml".source = tomlFormat.generate "zfetch-config.toml" {
      userspace = {
        packages = false;
        ui = false;

        colors_style = "box";
      };

      display = {
        box_style = "square";
      };
    };
  };
}
