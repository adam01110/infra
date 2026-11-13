{
  flake.modules = {
    nixos.hyprland.services.gnome.at-spi2-core.enable = true;

    homeManager.albedo = {
      # keep-sorted start
      lib,
      pkgs,
      # keep-sorted end
      ...
    }: let
      inherit (lib) getExe;

      inherit (pkgs.nur.repos.adam0) hypruse;
    in {
      dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
      home.packages = [hypruse];

      programs.albedo.mcp.servers.computer-use = {
        description = "Observe and control the real Hyprland desktop: windows, apps, input and screenshots. Explicit request only.";
        command = getExe hypruse;
        environment = {
          # keep-sorted start
          HYPRUSE_AUTH_GUARD = "strict";
          HYPRUSE_SCREENSHOT_MODE = "image";
          HYPRUSE_STRICT = "1";
          # keep-sorted end
        };
      };
    };
  };
}
