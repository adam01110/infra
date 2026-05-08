{self, ...}: {
  flake.modules.homeManager.nh = {vars, ...}: let
    inherit (vars) username;
  in {
    imports = [self.modules.generic.vars];

    programs.nh = {
      enable = true;

      # Set flake root.
      flake = "/home/${username}/Nixos";
    };
  };
}
