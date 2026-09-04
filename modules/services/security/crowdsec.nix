{inputs, ...}: {
  flake-file = {
    inputs.nixpkgs-crowdsec = {
      url = "github:TornaxO7/nixpkgs/saltsprint";
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

  flake.modules.nixos.crowdsec-base = {
    # keep-sorted start
    config,
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
          "crowdsecurity/linux"
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

    users = {
      groups.${config.services.crowdsec.group} = {};

      users.${config.services.crowdsec.user} = {
        group = config.services.crowdsec.group;
        isSystemUser = true;
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
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkForce
      mkMerge
      # keep-sorted end
      ;
    secrets = config.sops.secrets;
    templates = config.sops.templates;

    dataDir = "/var/lib/crowdsec/data";
    lapiPort = 8080;
    metricsPort = 6060;
    proxyPort = "12346";

    setupDeps = [
      # keep-sorted start
      "postgresql.service"
      "sops-install-secrets.service"
      # keep-sorted end
    ];

    setupUnit = {
      after = setupDeps;
      wants = setupDeps;
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

      templates."crowdsec-blocklist-import-env" = {
        mode = "0640";
        owner = config.services.crowdsec.user;
        group = config.services.crowdsec.group;
        path = "/etc/crowdsec/blocklist-import.env";
        content = ''
          WEBHOOK_TYPE: "generic"
          WEBHOOK_URL=http://127.0.0.1:${proxyPort}
        '';
      };
    };

    networking.firewall.interfaces = {
      ${config.services.homelabWireguard.interface}.allowedTCPPorts = [lapiPort];
      br-crowdsec.allowedTCPPorts = [
        metricsPort
        lapiPort
      ];
    };

    services = {
      crowdsec.settings = {
        config = {
          api.server = {
            # Accepts remote clients only through the WireGuard firewall rule.
            listen_uri = "0.0.0.0:${toString lapiPort}";

            online_client.credentials_path = "${dataDir}/online_api_credentials.yaml";
          };

          db_config = {
            db_name = "crowdsec";
            db_path = "/run/postgresql";
            type = "pgx";
            user = "crowdsec";
          };

          prometheus = {
            enabled = true;
            level = "full";
            listen_addr = "0.0.0.0";
            listen_port = metricsPort;
          };
        };

        console.enrollKeyFile = secrets."crowdsec/console_enroll_key".path;

        profiles = [
          {
            decisions = [
              {
                duration = "4h";
                type = "ban";
              }
            ];

            filters = [''Alert.Remediation == true && Alert.GetScope() == "Ip"''];
            name = "default_ip_remediation";
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
            name = "default_ip_remediation";
            on_success = "break";
          }
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

      # Reloading leaves AppSec acquisition stopped on CrowdSec 1.7.8.
      crowdsec-update-hub.serviceConfig.ExecStartPost = mkForce ["+systemctl restart crowdsec.service"];

      crowdsec-blocklist-import-frequent = {
        after = [
          # keep-sorted start
          "crowdsec-blocklist-gotify-proxy.service"
          "crowdsec-firewall-bouncer-register.service"
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];
        wants = [
          # keep-sorted start
          "crowdsec-blocklist-gotify-proxy.service"
          "crowdsec-firewall-bouncer-register.service"
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];

        serviceConfig = {
          EnvironmentFile = templates."crowdsec-blocklist-import-env".path;
          StateDirectory = mkForce [];

          ReadWritePaths = [
            # keep-sorted start
            "/var/lib/crowdsec"
            "/var/lib/crowdsec-firewall-bouncer-register"
            # keep-sorted end
          ];
        };
      };

      crowdsec-blocklist-import-limited = {
        after = [
          # keep-sorted start
          "crowdsec-blocklist-gotify-proxy.service"
          "crowdsec-firewall-bouncer-register.service"
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];
        wants = [
          # keep-sorted start
          "crowdsec-blocklist-gotify-proxy.service"
          "crowdsec-firewall-bouncer-register.service"
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];

        serviceConfig = {
          EnvironmentFile = templates."crowdsec-blocklist-import-env".path;
          StateDirectory = mkForce [];

          ReadWritePaths = [
            # keep-sorted start
            "/var/lib/crowdsec"
            "/var/lib/crowdsec-firewall-bouncer-register"
            # keep-sorted end
          ];
        };
      };

      crowdsec-blocklist-gotify-proxy = {
        description = "Transform blocklist-import webhook payload for Gotify";

        after = [
          # keep-sorted start
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];
        stopIfChanged = false;
        wants = [
          # keep-sorted start
          "gotify-server.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];

        wantedBy = [
          # keep-sorted start
          "crowdsec-blocklist-import-frequent.service"
          "crowdsec-blocklist-import-limited.service"
          # keep-sorted end
        ];

        serviceConfig = {
          # keep-sorted start
          DynamicUser = true;
          ExecStart = "${getExe pkgs.socat} TCP-LISTEN:${proxyPort},bind=127.0.0.1,fork,reuseaddr SYSTEM:${getExe pkgs.crowdsec-blocklist-gotify-proxy}";
          LoadCredential = ["gotify_api_key:${secrets."crowdsec/gotify_api_key".path}"];
          Restart = "on-failure";
          SuccessExitStatus = [143];
          Type = "simple";
          # keep-sorted end
        };
      };

      # PostgreSQL local socket access.
      crowdsec-firewall-bouncer-register.serviceConfig.RestrictAddressFamilies = mkForce ["AF_UNIX"];

      crowdsec-traefik-bouncer = {
        description = "Register Traefik CrowdSec bouncer";

        # keep-sorted start block=yes newline_separated=yes
        after = [
          # keep-sorted start
          "crowdsec.service"
          "sops-install-secrets.service"
          # keep-sorted end
        ];

        before = ["traefik.service"];

        wantedBy = ["traefik.service"];

        wants = [
          # keep-sorted start
          "crowdsec.service"
          "sops-install-secrets.service"
          # keep-sorted end
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

        serviceConfig = mkMerge [
          {
            StateDirectory = mkForce [];

            ReadWritePaths = [
              # keep-sorted start
              "/var/lib/crowdsec"
              dataDir
              # keep-sorted end
            ];
          }

          {
            # keep-sorted start
            DynamicUser = true;
            Group = config.services.crowdsec.group;
            User = config.services.crowdsec.user;
            # keep-sorted end

            # keep-sorted start
            LoadCredential = ["traefik_bouncer_key:${secrets."traefik/crowdsec_bouncer_key".path}"];
            RemainAfterExit = true;
            Type = "oneshot";
            # keep-sorted end
          }
        ];
      };
    };
  };
}
