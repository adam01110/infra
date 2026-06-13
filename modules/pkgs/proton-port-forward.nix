{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.proton-port-forward = writeShellApplication {
      name = "proton-port-forward";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        curl
        gnused
        iproute2
        jq
        libnatpmp
        nftables
        podman
        # keep-sorted end
      ];
      text = ''
        set -eu

        state_dir=/run/proton-wireguard
        port_file="$state_dir/forwarded_port"
        nft_table=proton-wireguard-port-forward

        mkdir -p "$state_dir"

        cleanup() {
          nft delete table ip "$nft_table" 2>/dev/null || true
        }

        trap cleanup EXIT INT TERM

        ensure_policy_routing() {
          ip -4 route replace "$PROTON_GATEWAY" dev "$WIREGUARD_INTERFACE"
          ip -4 route replace default dev "$WIREGUARD_INTERFACE" table "$ROUTING_TABLE"

          for subnet in $PRIVATE_IPV4_SUBNETS; do
            ip -4 rule del from "$CONTAINER_IPV4_SUBNET" to "$subnet" table main priority 900 2>/dev/null || true
            ip -4 rule add from "$CONTAINER_IPV4_SUBNET" to "$subnet" table main priority 900
          done

          ip -4 rule del from "$CONTAINER_IPV4_SUBNET" table "$ROUTING_TABLE" priority 1000 2>/dev/null || true
          ip -4 rule add from "$CONTAINER_IPV4_SUBNET" table "$ROUTING_TABLE" priority 1000
        }

        resolve_container_ipv4() {
          container="$1"
          network="$2"

          podman inspect --type container --format json "$container" 2>/dev/null \
            | jq -r --arg network "$network" '.[0].NetworkSettings.Networks[$network].IPAddress // empty'
        }

        update_qbittorrent() {
          port="$1"
          qui_ipv4="$2"
          proxy_path="$(tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/qui_qbittorrent_proxy_path")"

          case "$proxy_path" in
            /*) ;;
            *) proxy_path="/$proxy_path" ;;
          esac

          curl \
            --fail \
            --silent \
            --show-error \
            --data-urlencode "json={\"listen_port\":$port,\"upnp\":false}" \
            "http://$qui_ipv4:$QUI_PORT$proxy_path/api/v2/app/setPreferences" >/dev/null
        }

        while true; do
          ensure_policy_routing

          udp_output=$(natpmpc -a 1 0 udp 60 -g "$PROTON_GATEWAY")
          tcp_output=$(natpmpc -a 1 0 tcp 60 -g "$PROTON_GATEWAY")

          udp_port=$(printf '%s\n' "$udp_output" | sed -n 's/.*Mapped public port \([0-9][0-9]*\).*/\1/p;T;q')
          tcp_port=$(printf '%s\n' "$tcp_output" | sed -n 's/.*Mapped public port \([0-9][0-9]*\).*/\1/p;T;q')

          if [ -z "$udp_port" ] || [ -z "$tcp_port" ] || [ "$udp_port" != "$tcp_port" ]; then
            printf 'failed to get matching Proton forwarded ports\nUDP output:\n%s\nTCP output:\n%s\n' "$udp_output" "$tcp_output" >&2
            nft delete table ip "$nft_table" 2>/dev/null || true
            sleep 45
            continue
          fi

          printf '%s\n' "$udp_port" > "$port_file"

          qbittorrent_ipv4="$(resolve_container_ipv4 "$QBITTORRENT_CONTAINER" "$QBITTORRENT_NETWORK")"
          qui_ipv4="$(resolve_container_ipv4 "$QUI_CONTAINER" "$QUI_NETWORK")"

          if [ -z "$qbittorrent_ipv4" ]; then
            printf 'waiting for container: %s\n' "$QBITTORRENT_CONTAINER" >&2
            nft delete table ip "$nft_table" 2>/dev/null || true
            sleep 45
            continue
          fi

          if [ -z "$qui_ipv4" ]; then
            printf 'skipping qBittorrent API update until %s is available\n' "$QUI_CONTAINER" >&2
          elif ! update_qbittorrent "$udp_port" "$qui_ipv4"; then
            printf 'failed to update qBittorrent listening port to %s\n' "$udp_port" >&2
          fi

          nft delete table ip "$nft_table" 2>/dev/null || true
          nft -f - <<EOF
        table ip $nft_table {
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "$WIREGUARD_INTERFACE" tcp dport $udp_port dnat to $qbittorrent_ipv4:$udp_port
            iifname "$WIREGUARD_INTERFACE" udp dport $udp_port dnat to $qbittorrent_ipv4:$udp_port
          }
        }
        EOF

          sleep 45
        done
      '';
    };
  };
}
