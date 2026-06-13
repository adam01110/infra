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
          ip -4 route del "$PROTON_GATEWAY" dev "$WIREGUARD_INTERFACE" 2>/dev/null || true
          nft delete table ip "$nft_table" 2>/dev/null || true
        }

        trap cleanup EXIT INT TERM

        ip -4 route replace "$PROTON_GATEWAY" dev "$WIREGUARD_INTERFACE"

        resolve_container_ipv4() {
          container="$1"
          network="$2"

          podman inspect \
            --format "{{ with index .NetworkSettings.Networks \"$network\" }}{{ .IPAddress }}{{ end }}" \
            "$container"
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
          udp_output=$(natpmpc -a 1 0 udp 60 -g "$PROTON_GATEWAY")
          tcp_output=$(natpmpc -a 1 0 tcp 60 -g "$PROTON_GATEWAY")

          udp_port=$(printf '%s\n' "$udp_output" | sed -n 's/.*Mapped public port \([0-9][0-9]*\).*/\1/p;T;q')
          tcp_port=$(printf '%s\n' "$tcp_output" | sed -n 's/.*Mapped public port \([0-9][0-9]*\).*/\1/p;T;q')

          if [ -z "$udp_port" ] || [ -z "$tcp_port" ] || [ "$udp_port" != "$tcp_port" ]; then
            printf 'failed to get matching Proton forwarded ports\nUDP output:\n%s\nTCP output:\n%s\n' "$udp_output" "$tcp_output" >&2
            exit 1
          fi

          printf '%s\n' "$udp_port" > "$port_file"

          qbittorrent_ipv4="$(resolve_container_ipv4 "$QBITTORRENT_CONTAINER" "$QBITTORRENT_NETWORK")"
          qui_ipv4="$(resolve_container_ipv4 "$QUI_CONTAINER" "$QUI_NETWORK")"

          if [ -z "$qbittorrent_ipv4" ] || [ -z "$qui_ipv4" ]; then
            printf 'failed to resolve container IPs: %s=%s %s=%s\n' "$QBITTORRENT_CONTAINER" "$qbittorrent_ipv4" "$QUI_CONTAINER" "$qui_ipv4" >&2
            exit 1
          fi

          if ! update_qbittorrent "$udp_port" "$qui_ipv4"; then
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
