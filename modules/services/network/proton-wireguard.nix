{
  flake.modules.nixos.protonWireguard = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe getExe';

    interface = "proton0";
    gateway = "10.2.0.1";
    routingTable = 51820;

    # keep-sorted start
    containerIPv4Gateway = "10.89.50.1";
    containerIPv4Subnet = "10.89.50.0/24";
    # keep-sorted end

    ip = getExe' pkgs.iproute2 "ip";
    secret = config.sops.placeholder;
    secretPrefix = "wireguard/${config.networking.hostName}/proton";

    privateIPv4Subnets = [
      # keep-sorted start
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # keep-sorted end
    ];

    routingTableString = toString routingTable;

    privateSubnetPostUpRules = builtins.concatStringsSep "\n" (map (subnet: ''
        ${ip} -4 rule del from ${containerIPv4Subnet} to ${subnet} table main priority 900 2>/dev/null || true
        ${ip} -4 rule add from ${containerIPv4Subnet} to ${subnet} table main priority 900
      '')
      privateIPv4Subnets);

    privateSubnetPreDownRules = builtins.concatStringsSep "\n" (map (subnet: ''
        ${ip} -4 rule del from ${containerIPv4Subnet} to ${subnet} table main priority 900 2>/dev/null || true
      '')
      privateIPv4Subnets);

    postUp = ''
      ${ip} -4 route replace ${gateway} dev ${interface}
      ${ip} -4 route replace default dev ${interface} table ${routingTableString}
      ${privateSubnetPostUpRules}
      ${ip} -4 rule del from ${containerIPv4Subnet} table ${routingTableString} priority 1000 2>/dev/null || true
      ${ip} -4 rule add from ${containerIPv4Subnet} table ${routingTableString} priority 1000
    '';

    preDown = ''
      ${ip} -4 rule del from ${containerIPv4Subnet} table ${routingTableString} priority 1000 2>/dev/null || true
      ${privateSubnetPreDownRules}
      ${ip} -4 route del default dev ${interface} table ${routingTableString} 2>/dev/null || true
      ${ip} -4 route del ${gateway} dev ${interface} 2>/dev/null || true
    '';
  in {
    sops = {
      secrets = {
        # keep-sorted start
        "${secretPrefix}/address" = {};
        "${secretPrefix}/allowed_ips" = {};
        "${secretPrefix}/dns" = {};
        "${secretPrefix}/endpoint" = {};
        "${secretPrefix}/private_key" = {};
        "${secretPrefix}/proxy/password" = {};
        "${secretPrefix}/proxy/user" = {};
        "${secretPrefix}/public_key" = {};
        qbittorrent_proxy_path = {};
        # keep-sorted end
      };

      templates."${interface}.conf" = {
        mode = "0400";
        content = ''
          [Interface]
          PrivateKey = ${secret."${secretPrefix}/private_key"}
          Address = ${secret."${secretPrefix}/address"}
          DNS = ${secret."${secretPrefix}/dns"}
          MTU = 1280
          Table = ${routingTableString}

          [Peer]
          PublicKey = ${secret."${secretPrefix}/public_key"}
          AllowedIPs = ${secret."${secretPrefix}/allowed_ips"}
          Endpoint = ${secret."${secretPrefix}/endpoint"}
          PersistentKeepalive = 25
        '';
      };
    };

    systemd.services = {
      "wg-quick-${interface}" = {
        # keep-sorted start
        after = ["sops-install-secrets.service"];
        wants = ["sops-install-secrets.service"];
        # keep-sorted end
      };

      proton-port-forward = {
        description = "Maintain Proton VPN port forwarding";

        # keep-sorted start block=yes newline_separated=yes
        after = [
          # keep-sorted start
          "nftables.service"
          "sops-install-secrets.service"
          "wg-quick-${interface}.service"
          # keep-sorted end
        ];

        wantedBy = ["multi-user.target"];

        wants = [
          # keep-sorted start
          "sops-install-secrets.service"
          "wg-quick-${interface}.service"

          # keep-sorted end
        ];
        # keep-sorted end

        environment = {
          # keep-sorted start
          CONTAINER_IPV4_SUBNET = containerIPv4Subnet;
          PRIVATE_IPV4_SUBNETS = builtins.concatStringsSep " " privateIPv4Subnets;
          PROTON_GATEWAY = gateway;
          QBITTORRENT_CONTAINER = "qbittorrent";
          QBITTORRENT_NETWORK = "vpn";
          QUI_CONTAINER = "qui";
          QUI_NETWORK = "torrent";
          QUI_PORT = "7476";
          ROUTING_TABLE = routingTableString;
          WIREGUARD_INTERFACE = interface;
          # keep-sorted end
        };

        serviceConfig = {
          ExecStart = getExe pkgs.proton-port-forward;
          LoadCredential = ["qui_qbittorrent_proxy_path:${config.sops.secrets.qbittorrent_proxy_path.path}"];

          # keep-sorted start
          Restart = "always";
          RestartSec = "5s";
          # keep-sorted end
        };
      };

      proton-indexer-proxy = {
        description = "HTTP proxy for selected Prowlarr indexers over Proton VPN";

        # keep-sorted start block=yes newline_separated=yes
        after = [
          # keep-sorted start
          "nftables.service"
          "sops-install-secrets.service"
          "wg-quick-${interface}.service"
          # keep-sorted end
        ];

        wantedBy = ["multi-user.target"];

        wants = [
          # keep-sorted start
          "sops-install-secrets.service"
          "wg-quick-${interface}.service"
          # keep-sorted end
        ];
        # keep-sorted end

        environment.PROXY_LISTEN_ADDRESS = containerIPv4Gateway;

        serviceConfig = {
          DynamicUser = true;
          ExecStart = getExe pkgs.proton-indexer-proxy;
          RuntimeDirectory = "proton-indexer-proxy";

          LoadCredential = [
            # keep-sorted start
            "proxy_password:${config.sops.secrets."${secretPrefix}/proxy/password".path}"
            "proxy_user:${config.sops.secrets."${secretPrefix}/proxy/user".path}"
            # keep-sorted end
          ];

          # keep-sorted start
          Restart = "always";
          RestartSec = "5s";
          # keep-sorted end
        };
      };
    };

    networking = {
      firewall = {
        checkReversePath = "loose";

        extraInputRules = ''
          iifname "podman*" tcp dport 8888 accept
        '';
      };

      nftables = {
        enable = true;
        ruleset = ''
          table ip proton-wireguard-nat {
            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;
              ip saddr ${containerIPv4Subnet} oifname "${interface}" masquerade
            }
          }

          table inet proton-wireguard-filter {
            chain forward {
              type filter hook forward priority -5; policy accept;
              ct state established,related accept
              iifname "podman*" oifname "podman*" ip saddr ${containerIPv4Subnet} accept
              iifname "podman*" oifname "${interface}" ip saddr ${containerIPv4Subnet} accept
              iifname "podman*" ip saddr ${containerIPv4Subnet} reject
            }
          }
        '';
      };

      wg-quick.interfaces.${interface} = {
        autostart = true;
        configFile = config.sops.templates."${interface}.conf".path;

        inherit
          # keep-sorted start
          postUp
          preDown
          # keep-sorted end
          ;
      };
    };
  };
}
