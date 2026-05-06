{inputs, ...}: {
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  flake.overlays.determinate = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
  in {
    nix = inputs.determinate.packages.${system}.default;
  };
}
