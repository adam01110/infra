{
  flake.modules.homeManager.nh = {vars, ...}: let
    inherit (vars) username;
  in {
    programs.nh = {
      enable = true;

      flake = "/home/${username}/Infra";
    };
  };
}
