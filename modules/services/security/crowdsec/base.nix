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

    environment.etc."crowdsec/postoverflows/s01-whitelist/curacao.yaml".source =
      config.sops.templates."crowdsec-curacao-whitelist.yaml".path;

    sops = {
      secrets."crowdsec/curacao" = {};

      templates."crowdsec-curacao-whitelist.yaml" = {
        content = ''
          name: local/curacao
          description: "Whitelist Curacao dynamic IP"
          whitelist:
            reason: "Curacao dynamic DNS address"
            expression:
              - evt.Overflow.Alert.Source.IP in LookupHost("${config.sops.placeholder."crowdsec/curacao"}")
        '';
        group = config.services.crowdsec.group;
        mode = "0440";
        owner = config.services.crowdsec.user;
        restartUnits = ["crowdsec.service"];
      };
    };

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
