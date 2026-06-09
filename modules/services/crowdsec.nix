{inputs, ...}: {
  flake-file = {
    inputs.nixpkgs-crowdsec = {
      url = "github:TornaxO7/nixpkgs/crowdsec";
    };

    inputs.nixpkgs-crowdsec-blocklist-import = {
      url = "github:gaelj/nixpkgs/init-crowdsec-blocklist-import";
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
      "${inputs.nixpkgs-crowdsec-blocklist-import}/nixos/modules/services/security/crowdsec-blocklist-import.nix"
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
          "firix/authentik"
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
            journalctl_filter = [
              "_SYSTEMD_UNIT=authentik.service"
              "_SYSTEMD_UNIT=authentik-worker.service"
            ];
            labels.type = "authentik";
            source = "journalctl";
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
    lib,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    secrets = config.sops.secrets;

    dataDir = "/var/lib/crowdsec/data";
    gotifyUrl = "https://127.0.0.1:4407/message";

    setupDeps = [
      "postgresql.service"
      "sops-install-secrets.service"
    ];

    setupUnit = {
      after = setupDeps;
      requires = setupDeps;
    };
  in {
    imports = [self.modules.nixos.crowdsec-base];

    sops = {
      secrets = {
        # keep-sorted start
        "crowdsec/console_enroll_key" = {};
        "crowdsec/gotify_api_key" = {};
        "traefik/crowdsec_bouncer_key" = {};
        # keep-sorted end
      };

      templates."crowdsec-gotify-notification" = {
        path = "/etc/crowdsec/notifications/gotify-alerts.yaml";
        content = ''
          type: http
          name: gotify_alerts
          log_level: info
          url: ${gotifyUrl}
          method: POST
          headers:
            X-Gotify-Key: ${config.sops.placeholder."crowdsec/gotify_api_key"}
            Content-Type: application/json
            skip_tls_verification: true
          format: |
            {{ range . -}}
            {{ $alert := . -}}
            {
              "extras": {
                "client::display": {
                  "contentType": "text/markdown"
                }
              },
              "priority": 3,
              {{range .Decisions -}}
              "title": "{{.Type }} {{ .Value }} for {{.Duration}}",
              "message": "{{.Scenario}}\n\n[crowdsec cti](https://app.crowdsec.net/cti/{{.Value -}})\n\n[shodan](https://www.shodan.io/host/{{.Value -}})"
              {{end -}}
            }
            {{ end -}}
        '';
      };
    };

    services = {
      crowdsec.settings = {
        config = {
          api.server.online_client.credentials_path = "${dataDir}/online_api_credentials.yaml";

          db_config = {
            db_name = "crowdsec";
            db_path = "/run/postgresql";
            type = "pgx";
            user = "crowdsec";
          };
        };

        console.enrollKeyFile = secrets."crowdsec/console_enroll_key".path;

        profiles = mkForce [
          # keep-sorted start
          {
            decisions = [
              {
                duration = "4h";
                type = "ban";
              }
            ];
            filters = [''Alert.Remediation == true && Alert.GetScope() == "Ip"''];
            name = "default_ip_remediation";
            notifications = ["gotify_alerts"];
            on_success = "break";
          }
          {
            decisions = [
              {
                duration = "4h";
                type = "ban";
              }
            ];
            filters = [''Alert.Remediation == true && Alert.GetScope() == "Range"''];
            name = "default_range_remediation";
            notifications = ["gotify_alerts"];
            on_success = "break";
          }
          # keep-sorted end
        ];
      };

      crowdsec-firewall-bouncer = {
        enable = true;
        registerBouncer.enable = true;
        createRulesets = true;
      };

      crowdsec-blocklist-import = {
        enable = true;
        allowListGithub = true;
      };
    };

    systemd.services = {
      crowdsec = setupUnit;
      crowdsec-setup = setupUnit;

      # PostgreSQL local socket access.
      crowdsec-firewall-bouncer-register.serviceConfig.RestrictAddressFamilies = mkForce ["AF_UNIX"];

      crowdsec-traefik-bouncer = {
        description = "Register Traefik CrowdSec bouncer";

        # keep-sorted start block=yes newline_separated=yes
        after = [
          "crowdsec.service"
          "sops-install-secrets.service"
        ];

        before = ["traefik.service"];

        requiredBy = ["traefik.service"];

        requires = [
          "crowdsec.service"
          "sops-install-secrets.service"
        ];
        # keep-sorted end

        script = ''
          set -eu

          attempt=1
          while [ "$attempt" -le 30 ]; do
            if ${pkgs.crowdsec}/bin/cscli bouncers list | ${pkgs.gnugrep}/bin/grep -q "traefik-bouncer"; then
              exit 0
            fi

            if ${pkgs.crowdsec}/bin/cscli bouncers add "traefik-bouncer" --key "$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/traefik_bouncer_key")" >/dev/null; then
              exit 0
            fi

            attempt=$((attempt + 1))
            ${pkgs.coreutils}/bin/sleep 2
          done

          ${pkgs.crowdsec}/bin/cscli bouncers list
          exit 1
        '';

        serviceConfig = {
          # keep-sorted start
          DynamicUser = true;
          Group = config.services.crowdsec.group;
          StateDirectory = "crowdsec";
          StateDirectoryMode = "0750";
          User = config.services.crowdsec.user;
          # keep-sorted end

          # keep-sorted start
          LoadCredential = ["traefik_bouncer_key:${secrets."traefik/crowdsec_bouncer_key".path}"];
          RemainAfterExit = true;
          Type = "oneshot";
          # keep-sorted end
        };
      };
    };
  };
}
