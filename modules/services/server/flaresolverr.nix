{
  flake.modules.nixos.flaresolverr = {
    services.flaresolverr.enable = true;

    networking.firewall.extraInputRules = ''
      iifname "podman*" tcp dport 8191 accept
    '';
  };
}
