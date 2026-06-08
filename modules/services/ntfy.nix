{
  flake.modules.nixos.ntfy = {vars, ...}: let
    inherit (vars) groundDomain;
  in {
    services.ntfy = {
      enable = true;

      settings = {
        base-url = "https://ntfy.${groundDomain}";
      };
    };
  };
}
