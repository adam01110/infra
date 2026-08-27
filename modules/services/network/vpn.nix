{
  flake.modules.nixos.vpn = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      boolToString
      concatMapAttrs
      mapAttrs'
      mkOption
      nameValuePair
      types
      # keep-sorted end
      ;

    cfg = config.services.wireguardVpns;
    secret = config.sops.placeholder;
    secretPrefix = location: "wireguard/${location}";
  in {
    options.services.wireguardVpns = mkOption {
      default = {};
      description = "WireGuard VPN locations managed by NetworkManager.";
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          # keep-sorted start block=yes newline_separated=yes
          autoconnect = mkOption {
            default = false;
            description = "Connect this VPN during boot.";
            type = types.bool;
          };

          interface = mkOption {
            default = name;
            description = "WireGuard interface name.";
            type = types.strMatching "[a-zA-Z0-9_=+.-]{1,15}";
          };

          persistentKeepalive = mkOption {
            default = 25;
            description = "Peer keepalive interval in seconds.";
            type = types.ints.positive;
          };
          # keep-sorted end
        };
      }));
    };

    config = {
      sops = {
        secrets =
          concatMapAttrs (location: _: let
            prefix = secretPrefix location;
          in {
            # keep-sorted start
            "${prefix}/address_ipv4" = {};
            "${prefix}/address_ipv6" = {};
            "${prefix}/allowed_ipv4" = {};
            "${prefix}/allowed_ipv6" = {};
            "${prefix}/dns_ipv4" = {};
            "${prefix}/dns_ipv6" = {};
            "${prefix}/endpoint" = {};
            "${prefix}/private_key" = {};
            "${prefix}/public_key" = {};
            # keep-sorted end
          })
          cfg;

        templates = mapAttrs' (location: vpn: let
          prefix = secretPrefix location;
        in
          nameValuePair "${vpn.interface}.nmconnection" {
            mode = "0600";
            path = "/run/NetworkManager/system-connections/${location}.nmconnection";
            reloadUnits = ["NetworkManager.service"];
            content = ''
              [connection]
              id=${location}
              type=wireguard
              interface-name=${vpn.interface}
              autoconnect=${boolToString vpn.autoconnect}

              [wireguard]
              private-key=${secret."${prefix}/private_key"}
              peer-routes=true

              [wireguard-peer.${secret."${prefix}/public_key"}]
              endpoint=${secret."${prefix}/endpoint"}
              allowed-ips=${secret."${prefix}/allowed_ipv4"};${secret."${prefix}/allowed_ipv6"};
              persistent-keepalive=${toString vpn.persistentKeepalive}

              [ipv4]
              address1=${secret."${prefix}/address_ipv4"}
              dns=${secret."${prefix}/dns_ipv4"}
              method=manual

              [ipv6]
              address1=${secret."${prefix}/address_ipv6"}
              dns=${secret."${prefix}/dns_ipv6"}
              method=manual
            '';
          })
        cfg;
      };

      systemd.services.NetworkManager = {
        # keep-sorted start
        after = ["sops-install-secrets.service"];
        wants = ["sops-install-secrets.service"];
        # keep-sorted end
      };
    };
  };
}
