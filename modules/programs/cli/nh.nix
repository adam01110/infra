{
  flake.modules.homeManager.nh = {vars, ...}: let
    inherit (vars) username;
  in {
    programs.nh = {
      enable = true;

      # Set flake root.
      flake = "/home/${username}/Infra";
    };
  };
}
