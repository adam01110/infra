{inputs, ...}: {
  flake-file = {
    inputs.nixpkgs-crowdsec = {
      url = "github:TornaxO7/nixpkgs/crowdsec";
    };
  };

  flake.overlays.crowdsec = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    crowdsecPkgs = inputs.nixpkgs-crowdsec.legacyPackages.${system};
  in {
    inherit
      (crowdsecPkgs)
      # keep-sorted start
      crowdsec
      crowdsec-firewall-bouncer
      # keep-sorted end
      ;
  };

  flake.modules.nixos.crowdsec-base = {self, ...}: {
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

    services.crowdsec = {
      enable = true;
      autoUpdateService = true;
      openFirewall = false;

      hub = {
        collections = [
          # keep-sorted start
          "crowdsecurity/appsec-generic-rules"
          "crowdsecurity/appsec-virtual-patching"
          "crowdsecurity/http-cve"
          "crowdsecurity/linux"
          "crowdsecurity/sshd"
          "crowdsecurity/traefik"
          # keep-sorted end
        ];
      };

      settings = {
        acquisitions = [
          # keep-sorted start block=yes newline_separated=yes
          {
            appsec_configs = ["crowdsecurity/appsec-default"];
            labels.type = "appsec";
            listen_addr = "127.0.0.1:7424";
            source = "appsec";
          }

          {
            filenames = ["/var/log/traefik/*.log"];
            labels.type = "traefik";
            source = "file";
          }

          {
            journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
            labels.type = "syslog";
            source = "journalctl";
          }
          # keep-sorted end
        ];
      };
    };
  };

  flake.modules.nixos.crowdsec-agent = {self, ...}: {
    imports = [self.modules.nixos.crowdsec-base];

    services.crowdsec.settings.config.api.server.enable = false;
  };

  flake.modules.nixos.crowdsec-server = {
    # keep-sorted start
    config,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    dataDir = "/var/lib/crowdsec/data";
  in {
    imports = [self.modules.nixos.crowdsec-base];

    sops.secrets = {
      # keep-sorted start
      "crowdsec/console_enroll_key" = {};
      "traefik/crowdsec_bouncer_key" = {};
      # keep-sorted end
    };

    services.crowdsec.settings = {
      config = {
        api.server.online_client.credentials_path = "${dataDir}/online_api_credentials.yaml";

        db_config = {
          db_name = "crowdsec";
          db_path = "/run/postgresql";
          type = "pgx";
          user = "crowdsec";
        };
      };

      console.enrollKeyFile = config.sops.secrets."crowdsec/console_enroll_key".path;
    };

    services.postgresql = {
      ensureDatabases = ["crowdsec"];
      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "crowdsec";
        }
      ];
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
      registerBouncer.enable = true;
      createRulesets = true;
    };

    systemd.services = {
      # keep-sorted start block=yes newline_separated=yes
      crowdsec = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
      };

      crowdsec-setup = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
      };

      crowdsec-traefik-bouncer = {
        after = ["crowdsec.service"];
        before = ["traefik.service"];
        description = "Register Traefik CrowdSec bouncer";
        requiredBy = ["traefik.service"];
        requires = ["crowdsec.service"];

        script = ''
          set -eu

          attempt=1
          while [ "$attempt" -le 30 ]; do
            if ${pkgs.crowdsec}/bin/cscli bouncers list | ${pkgs.gnugrep}/bin/grep -q "traefik-bouncer"; then
              exit 0
            fi

            if ${pkgs.crowdsec}/bin/cscli bouncers add "traefik-bouncer" --key "$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/traefik_bouncer_key")"; then
              exit 0
            fi

            attempt=$((attempt + 1))
            ${pkgs.coreutils}/bin/sleep 2
          done

          ${pkgs.crowdsec}/bin/cscli bouncers list
          exit 1
        '';

        serviceConfig = {
          DynamicUser = true;
          Group = config.services.crowdsec.group;
          LoadCredential = [
            "traefik_bouncer_key:${config.sops.secrets."traefik/crowdsec_bouncer_key".path}"
          ];
          StateDirectory = "crowdsec";
          StateDirectoryMode = "0750";
          RemainAfterExit = true;
          Type = "oneshot";
          User = config.services.crowdsec.user;
        };
      };
      # keep-sorted end
    };
  };
}
