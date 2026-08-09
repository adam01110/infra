{
  flake.modules.homeManager.noctalia = {pkgs, ...}: {
    home.packages = [pkgs.ddcutil];

    programs.noctalia.settings = {
      audio.enable_overdrive = true;
      brightness.enable_ddcutil = true;
    };
  };
}
