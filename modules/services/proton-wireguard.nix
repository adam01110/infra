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
    containerIPv4Subnet = "10.89.50.0/24";
    gateway = "10.2.0.1";
    routingTable = 51820;
    secret = config.sops.placeholder;
    ip = getExe' pkgs.iproute2 "ip";

    postUp = ''
      ${ip} -4 route replace ${gateway} dev ${interface}
      ${ip} -4 route replace default dev ${interface} table ${toString routingTable}
      ${ip} -4 rule del from ${containerIPv4Subnet} table ${toString routingTable} priority 1000 2>/dev/null || true
      ${ip} -4 rule add from ${containerIPv4Subnet} table ${toString routingTable} priority 1000
    '';

    preDown = ''
      ${ip} -4 rule del from ${containerIPv4Subnet} table ${toString routingTable} priority 1000 2>/dev/null || true
      ${ip} -4 route del default dev ${interface} table ${toString routingTable} 2>/dev/null || true
      ${ip} -4 route del ${gateway} dev ${interface} 2>/dev/null || true
    '';
  in {
    sops = {
      secrets = {
        # keep-sorted start
        "wireguard/proton/address" = {};
        "wireguard/proton/allowed_ips" = {};
        "wireguard/proton/dns" = {};
        "wireguard/proton/endpoint" = {};
        "wireguard/proton/private_key" = {};
        "wireguard/proton/public_key" = {};
        qbittorrent_proxy_path = {};
        # keep-sorted end
      };

      templates."${interface}.conf" = {
        mode = "0400";
        content = ''
          [Interface]
          PrivateKey = ${secret."wireguard/proton/private_key"}
          Address = ${secret."wireguard/proton/address"}
          DNS = ${secret."wireguard/proton/dns"}
          MTU = 1420
          Table = ${toString routingTable}

          [Peer]
          PublicKey = ${secret."wireguard/proton/public_key"}
          AllowedIPs = ${secret."wireguard/proton/allowed_ips"}
          Endpoint = ${secret."wireguard/proton/endpoint"}
          PersistentKeepalive = 25
        '';
      };
    };

    systemd.services."wg-quick-${interface}" = {
      # keep-sorted start
      after = ["sops-install-secrets.service"];
      wants = ["sops-install-secrets.service"];
      # keep-sorted end
    };

    systemd.services.proton-port-forward = {
      after = [
        "nftables.service"
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];
      description = "Maintain Proton VPN port forwarding";
      environment = {
        CONTAINER_IPV4_SUBNET = containerIPv4Subnet;
        PROTON_GATEWAY = gateway;
        QBITTORRENT_CONTAINER = "qbittorrent";
        QBITTORRENT_NETWORK = "vpn";
        ROUTING_TABLE = toString routingTable;
        QUI_CONTAINER = "qui";
        QUI_NETWORK = "torrent";
        QUI_PORT = "7476";
        WIREGUARD_INTERFACE = interface;
      };
      wantedBy = ["multi-user.target"];
      wants = [
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];

      serviceConfig = {
        ExecStart = getExe pkgs.proton-port-forward;
        LoadCredential = ["qui_qbittorrent_proxy_path:${config.sops.secrets.qbittorrent_proxy_path.path}"];
        Restart = "always";
        RestartSec = "5s";
      };
    };

    networking = {
      # keep-sorted start block=yes newline_separated=yes
      firewall.checkReversePath = "loose";

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
              iifname "podman*" oifname "${interface}" ip saddr ${containerIPv4Subnet} accept
              iifname "podman*" ip saddr ${containerIPv4Subnet} reject
            }
          }
        '';
      };

      wg-quick.interfaces.${interface} = {
        # keep-sorted start
        autostart = true;
        configFile = config.sops.templates."${interface}.conf".path;
        inherit
          # keep-sorted start
          postUp
          preDown
          # keep-sorted end
          ;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
