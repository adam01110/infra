{
  inputs,
  self,
  ...
}: let
  lib = inputs.nixpkgs.lib.extend (_final: prev: {
    self = import "${self}/lib" {lib = prev;};
  });
in {
  flake.lib = lib;
}
