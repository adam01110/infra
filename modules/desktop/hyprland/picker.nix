{
  flake.modules.homeManager.hyprland = {pkgs, ...}: {
    home.packages = [pkgs.hyprpicker];
  };
}
