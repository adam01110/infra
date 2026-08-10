{
  flake.modules.homeManager.noctalia = {pkgs, ...}: {
    home.packages = [pkgs.ddcutil];
    programs.noctalia.settings.brightness.enable_ddcutil = true;
  };
}
