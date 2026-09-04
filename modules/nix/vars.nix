{self, ...}: let
  vars = import "${self}/vars.nix";
in {
  flake = {
    inherit vars;
    modules.generic.vars._module.args = {inherit vars;};
  };
}
