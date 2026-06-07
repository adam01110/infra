{
  flake.modules.nixos.ssh-stunnel = {vars, ...}: let
    inherit (vars) groundDomain;
  in {
    services.stunnel = {
      enable = true;

      clients.ssh-euclid = {
        accept = "127.0.0.1:2201";
        checkHost = "euclid.${groundDomain}";
        connect = "euclid.${groundDomain}:22";
        sni = "euclid.${groundDomain}";
      };
    };
  };
}
