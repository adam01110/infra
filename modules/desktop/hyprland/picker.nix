{pkgs, ...}: {
  flake.modules.homeManager.hyprland = {
    home.packages = [pkgs.hyprpicker];
  };
}
