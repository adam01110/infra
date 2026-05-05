{inputs, ...}: let
  vars = import "${inputs.self}/vars.nix";
in {
  flake.vars = vars;

  flake.modules.generic.vars = {
    _module.args.vars = vars;
  };
}
