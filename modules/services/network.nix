{
  flake.modules.nixos.network = {
    # keep-sorted start
    config,
    lib,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) concatStringsSep;
    inherit (vars) username;
  in {
    sops = let
      hostname = config.networking.hostName;
    in {
      secrets = {
        # keep-sorted start numeric=yes
        "dns/${hostname}/dns_1" = {};
        "dns/${hostname}/dns_2" = {};
        "dns/${hostname}/dns_3" = {};
        "dns/${hostname}/dns_4" = {};
        # keep-sorted end
      };

      # Template for resolved.conf carrying dns servers from sops.
      templates."resolved-dns.conf" = {
        mode = "0440";
        group = "systemd-resolve";

        content = let
          secret = config.sops.placeholder;
        in ''
          [Resolve]
          DNS=${concatStringsSep " " [
            secret."dns/${hostname}/dns_1"
            secret."dns/${hostname}/dns_2"
            secret."dns/${hostname}/dns_3"
            secret."dns/${hostname}/dns_4"
          ]}
        '';
      };
    };

    networking = {
      useDHCP = false;
      dhcpcd.enable = false;

      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
    };

    users.users.${username}.extraGroups = ["networkmanager"];

    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSOverTLS = "opportunistic";

        FallbackDNS = [
          # keep-sorted start
          "1.0.0.1#cloudflare-dns.com"
          "1.1.1.1#cloudflare-dns.com"
          "2606:4700:4700::1001#cloudflare-dns.com"
          "2606:4700:4700::1111#cloudflare-dns.com"
          # keep-sorted end
        ];
      };
    };

    systemd = {
      # Avoid blocking boot on network readiness.
      network.wait-online.enable = false;

      services.systemd-resolved = {
        wants = ["sops-nix.service"];
        after = ["sops-nix.service"];
      };
    };

    # Install the resolved dns rendered from sops.
    environment.etc."systemd/resolved.conf.d/00-dns.conf".source = config.sops.templates."resolved-dns.conf".path;
  };
}
