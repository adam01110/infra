{
  flake.aspects.noctalia = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.ddcutil];
      programs.noctalia.settings.brightness.enable_ddcutil = true;
    };

    nixos.hardware.i2c.enable = true;
  };
}
