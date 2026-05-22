{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs = {
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins?ref=v0.55.0";
      inputs.hyprland.follows = "hyprland";
    };
  };

  flake.modules.homeManager.hyprland = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    nixpkgs.overlays = [self.overlays.hyprland-plugins];

    wayland.windowManager.hyprland.plugins = [pkgs.hyprlandPlugins.hyprfocus];

    programs.nixhypr = {
      extraLuaSnippets = [
        ''
          -- Expose hyprsplit for keybind dispatchers.
          hyprsplit = dofile("${pkgs.nur.repos.adam0.hyprsplit}/init.lua")
          hyprsplit.config({ num_workspaces = 8 })
        ''
      ];

      settings.plugin.hyprfocus = {
        # keep-sorted start
        bounce_strength = 0.995;
        mode = "bounce";
        # keep-sorted end
      };
    };
  };

  flake.overlays.hyprland-plugins = final: prev: let
    inherit (final.stdenv.hostPlatform) system;
  in {
    hyprlandPlugins =
      prev.hyprlandPlugins
      // {inherit (inputs.hyprland-plugins.packages.${system}) hyprfocus;};
  };
}
