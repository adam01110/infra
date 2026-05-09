{inputs, ...}: let
  lib = inputs.nixpkgs.lib.extend (_final: prev: {
    self = import ../lib {lib = prev;};
  });
in {
  flake.lib = lib;
}
