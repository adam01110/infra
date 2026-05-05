{inputs, ...}: {
  flake-file.inputs = {
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  flake.overlays.determinate = final: _prev: {
    nix = inputs.determinate.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
