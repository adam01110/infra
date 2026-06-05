{inputs, ...}: {
  flake-file = {
    inputs.nixpkgs-crowdsec = {
      url = "github:TornaxO7/nixpkgs/crowdsec";
    };
  };

  flake.overlays.crowdsec = final: _prev: let
    crowdsecPkgs = inputs.nixpkgs-crowdsec.legacyPackages.${final.stdenv.hostPlatform.system};
  in {
    inherit
      (crowdsecPkgs)
      # keep-sorted start
      crowdsec
      crowdsec-firewall-bouncer
      # keep-sorted end
      ;
  };

  flake.modules.nixos.crowdsec = {
    # keep-sorted start
    config,
    self,
    # keep-sorted end
    ...
  }: let
    dataDir = "/var/lib/crowdsec/data";
  in {
    nixpkgs.overlays = [self.overlays.crowdsec];

    disabledModules = [
      # keep-sorted start
      "services/security/crowdsec-firewall-bouncer.nix"
      "services/security/crowdsec.nix"
      # keep-sorted end
    ];

    imports = [
      # keep-sorted start
      "${inputs.nixpkgs-crowdsec}/nixos/modules/services/security/crowdsec-firewall-bouncer.nix"
      "${inputs.nixpkgs-crowdsec}/nixos/modules/services/security/crowdsec.nix"
      # keep-sorted end
    ];

    sops.secrets."crowdsec/console_enroll_key" = {};

    services.crowdsec = {
      enable = true;
      autoUpdateService = true;
      openFirewall = false;

      hub = {
        collections = [
          # keep-sorted start
          #"crowdsecurity/appsec-generic-rules"
          #"crowdsecurity/appsec-virtual-patching"
          #"crowdsecurity/http-cve"
          "crowdsecurity/linux"
          "crowdsecurity/sshd"
          # keep-sorted end
        ];
      };

      settings = {
        acquisitions = [
          # keep-sorted start
          {
            journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
            labels.type = "syslog";
            source = "journalctl";
          }
          # keep-sorted end
        ];

        config.api.server.online_client.credentials_path = "${dataDir}/online_api_credentials.yaml";

        console.enrollKeyFile = config.sops.secrets."crowdsec/console_enroll_key".path;
      };
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
      registerBouncer.enable = true;
      createRulesets = true;
    };
  };
}
