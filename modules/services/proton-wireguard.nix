{
  flake.modules.nixos.protonWireguard = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) concatMapStringsSep;

    interface = "proton0";
    protonGateway = "10.2.0.1";
    qbittorrentContainer = "qbittorrent";
    qbittorrentNetwork = "vpn";
    quiContainer = "qui";
    quiNetwork = "torrent";
    quiPort = "7476";
    routingPriority = 1000;
    routingTable = "51820";
    containerIPv4Subnets = ["10.89.50.0/24"];

    sopsPlaceholder = config.sops.placeholder;
    template = config.sops.templates."${interface}.conf";

    containerIPv4Set = "{ ${concatMapStringsSep ", " (subnet: subnet) containerIPv4Subnets} }";

    addIpRules =
      ''
        ${pkgs.iproute2}/bin/ip -4 route add ${protonGateway} dev ${interface} 2>/dev/null || true
      ''
      + concatMapStringsSep "\n" (subnet: ''
        ${pkgs.iproute2}/bin/ip -4 rule add from ${subnet} table ${routingTable} priority ${toString routingPriority} 2>/dev/null || true
      '')
      containerIPv4Subnets;

    deleteIpRules =
      ''
        ${pkgs.iproute2}/bin/ip -4 route del ${protonGateway} dev ${interface} 2>/dev/null || true
      ''
      + concatMapStringsSep "\n" (subnet: ''
        ${pkgs.iproute2}/bin/ip -4 rule del from ${subnet} table ${routingTable} priority ${toString routingPriority} 2>/dev/null || true
      '')
      containerIPv4Subnets;
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
          PrivateKey = ${sopsPlaceholder."wireguard/proton/private_key"}
          Address = ${sopsPlaceholder."wireguard/proton/address"}
          DNS = ${sopsPlaceholder."wireguard/proton/dns"}
          MTU = 1420
          Table = ${routingTable}

          [Peer]
          PublicKey = ${sopsPlaceholder."wireguard/proton/public_key"}
          AllowedIPs = ${sopsPlaceholder."wireguard/proton/allowed_ips"}
          Endpoint = ${sopsPlaceholder."wireguard/proton/endpoint"}
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
        PROTON_GATEWAY = protonGateway;
        QBITTORRENT_CONTAINER = qbittorrentContainer;
        QBITTORRENT_NETWORK = qbittorrentNetwork;
        QUI_CONTAINER = quiContainer;
        QUI_NETWORK = quiNetwork;
        QUI_PORT = quiPort;
        WIREGUARD_INTERFACE = interface;
      };
      wantedBy = ["multi-user.target"];
      wants = [
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.proton-port-forward}/bin/proton-port-forward";
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
              ip saddr ${containerIPv4Set} oifname "${interface}" masquerade
            }
          }

          table inet proton-wireguard-filter {
            chain forward {
              type filter hook forward priority -5; policy accept;
              ct state established,related accept
              iifname "podman*" oifname "${interface}" ip saddr ${containerIPv4Set} accept
              iifname "podman*" ip saddr ${containerIPv4Set} reject
            }
          }
        '';
      };

      wg-quick.interfaces.${interface} = {
        # keep-sorted start
        autostart = true;
        configFile = template.path;
        postUp = addIpRules;
        preDown = deleteIpRules;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
