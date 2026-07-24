{
  flake.modules.nixos.flaresolverr = {
    services.flaresolverr.enable = true;

    # Bind only to WireGuard; containers route via wg0.
    systemd.services.flaresolverr.environment.HOST = "10.100.0.1";

    networking.firewall.extraInputRules = ''
      iifname "podman*" tcp dport 8191 accept
    '';
  };
}
