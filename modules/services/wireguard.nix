{
  flake.modules.nixos.wireguard = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      mkIf
      mkOption
      types
      # keep-sorted end
      ;

    cfg = config.services.homelabWireguard;
  in {
    options.services.homelabWireguard = {
      # keep-sorted start block=yes newline_separated=yes
      enable = mkOption {
        description = "Enable the homelab WireGuard interface.";

        default = false;
        type = types.bool;
      };

      interface = mkOption {
        description = "WireGuard interface name.";

        default = "wg0";
        type = types.str;
      };

      address = mkOption {
        description = "WireGuard interface address.";

        type = types.str;
        example = "10.100.0.1/24";
      };

      listenPort = mkOption {
        description = "WireGuard UDP listen port.";

        default = 51820;
        type = types.port;
      };

      privateKeySecret = mkOption {
        description = "Sops secret path containing the WireGuard private key.";

        type = types.str;
        example = "wireguard/euclid/private_key";
      };

      peers = mkOption {
        default = [];
        type = types.listOf (types.submodule {
          options = {
            publicKey = mkOption {
              description = "Peer public key.";

              type = types.str;
            };

            allowedIPs = mkOption {
              description = "Peer routes allowed through the tunnel.";

              type = types.listOf types.str;
              example = ["10.100.0.2/32"];
            };

            endpoint = mkOption {
              description = "Optional peer endpoint.";

              default = null;
              type = types.nullOr types.str;
            };

            persistentKeepalive = mkOption {
              description = "Optional keepalive interval in seconds.";

              default = null;
              type = types.nullOr types.ints.positive;
            };
          };
        });
        description = "WireGuard peers.";
      };
      # keep-sorted end
    };

    config = mkIf cfg.enable {
      sops.secrets.${cfg.privateKeySecret} = {};

      networking.wireguard.interfaces.${cfg.interface} = {
        ips = [cfg.address];

        inherit
          (cfg)
          # keep-sorted start
          listenPort
          peers
          # keep-sorted end
          ;

        privateKeyFile = config.sops.secrets.${cfg.privateKeySecret}.path;
      };

      networking.firewall.allowedUDPPorts = [cfg.listenPort];
    };
  };
}
