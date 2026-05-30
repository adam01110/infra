{inputs, ...}: {
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  flake.modules.generic.determinate = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    nix.package = inputs.determinate.inputs.nix.packages.${system}.default;

    nix.settings = let
      cache = "https://install.determinate.systems";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="];
    };
  };
}
