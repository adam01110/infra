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

    containerIPv4Subnet = "10.89.50.0/24";
    containerIPv4Gateway = "10.89.50.1";

    ip = getExe' pkgs.iproute2 "ip";
    secret = config.sops.placeholder;
    secretPrefix = "wireguard/${config.networking.hostName}/proton";

    privateIPv4Subnets = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
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

    systemd.services."wg-quick-${interface}" = {
      wants = ["sops-install-secrets.service"];
      after = ["sops-install-secrets.service"];
    };

    systemd.services.proton-port-forward = {
      description = "Maintain Proton VPN port forwarding";

      after = [
        "nftables.service"
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];
      wantedBy = ["multi-user.target"];
      wants = [
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];

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
        LoadCredential = [
          "qui_qbittorrent_proxy_path:${config.sops.secrets.qbittorrent_proxy_path.path}"
        ];
        Restart = "always";
        RestartSec = "5s";
      };
    };

    systemd.services.proton-indexer-proxy = {
      description = "HTTP proxy for selected Prowlarr indexers over Proton VPN";

      after = [
        "nftables.service"
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];
      wantedBy = ["multi-user.target"];
      wants = [
        "sops-install-secrets.service"
        "wg-quick-${interface}.service"
      ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = pkgs.writeShellScript "proton-indexer-proxy" ''
          set -eu

          config_file="$RUNTIME_DIRECTORY/tinyproxy.conf"
          password_file="$CREDENTIALS_DIRECTORY/proxy_password"
          user_file="$CREDENTIALS_DIRECTORY/proxy_user"

          cat > "$config_file" <<EOF
          Port 8888
          Listen ${containerIPv4Gateway}
          Bind ${containerIPv4Gateway}
          Timeout 600
          DisableViaHeader Yes
          Allow 10.0.0.0/8
          ConnectPort 443
          ConnectPort 563
          EOF

          if [ -s "$user_file" ] && [ -s "$password_file" ]; then
            username="$(tr -d '\r\n' < "$user_file")"
            password="$(tr -d '\r\n' < "$password_file")"
            printf 'BasicAuth %s %s\n' "$username" "$password" >> "$config_file"
          fi

          exec ${getExe pkgs.tinyproxy} -d -c "$config_file"
        '';
        LoadCredential = [
          "proxy_password:${config.sops.secrets."${secretPrefix}/proxy/password".path}"
          "proxy_user:${config.sops.secrets."${secretPrefix}/proxy/user".path}"
        ];
        Restart = "always";
        RestartSec = "5s";
        RuntimeDirectory = "proton-indexer-proxy";
      };
    };

    networking = {
      firewall.checkReversePath = "loose";

      firewall.extraInputRules = ''
        iifname "podman*" tcp dport 8888 accept
      '';

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
        inherit postUp preDown;
      };
    };
  };
}
