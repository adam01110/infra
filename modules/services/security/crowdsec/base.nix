{inputs, ...}: {
  flake.modules.nixos.crowdsec-base = {
    # keep-sorted start
    config,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: {
    nixpkgs.overlays = [self.overlays.crowdsec];

    disabledModules = [
      # keep-sorted start
      "services/security/crowdsec-firewall-bouncer.nix"
      "services/security/crowdsec.nix"
      # keep-sorted end
    ];

    imports = [
      # keep-sorted start
      "${inputs.nixpkgs-crowdsec-blocklist-import}/nixos/modules/services/security/crowdsec-blocklist-import.nix"
      "${inputs.nixpkgs-crowdsec}/nixos/modules/services/security/crowdsec-firewall-bouncer.nix"
      "${inputs.nixpkgs-crowdsec}/nixos/modules/services/security/crowdsec.nix"
      # keep-sorted end
    ];

    services.crowdsec = {
      enable = true;
      autoUpdateService = true;

      hub = {
        collections = [
          # keep-sorted start
          "LePresidente/jellyfin"
          "LePresidente/jellyseerr"
          "baudneo/gotify"
          "crowdsecurity/appsec-generic-rules"
          "crowdsecurity/appsec-virtual-patching"
          "crowdsecurity/http-cve"
          "crowdsecurity/sshd"
          "crowdsecurity/traefik"
          "firix/authentik"
          # keep-sorted end
        ];

        parsers = ["crowdsecurity/public-dns-allowlist"];

        postoverflows = [
          # keep-sorted start
          "crowdsecurity/cdn-whitelist"
          "crowdsecurity/rdns"
          # keep-sorted end
        ];
      };

      settings = {
        acquisitions = [
          {
            journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
            labels.type = "syslog";
            source = "journalctl";
          }
        ];
      };
    };

    # Removes whitelist resources left by the previously enabled Linux collection.
    systemd.services.crowdsec-setup.preStart = ''
      for collection in crowdsecurity/linux crowdsecurity/whitelist-good-actors; do
        ${pkgs.crowdsec}/bin/cscli collections remove "$collection" --force --purge || true
      done

      for postoverflow in crowdsecurity/google-special-crawlers-whitelist crowdsecurity/seo-bots-whitelist; do
        ${pkgs.crowdsec}/bin/cscli postoverflows remove "$postoverflow" --force --purge || true
      done
    '';

    users = {
      groups.${config.services.crowdsec.group} = {};

      users.${config.services.crowdsec.user} = {
        group = config.services.crowdsec.group;
        isSystemUser = true;
      };
    };
  };
}
