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
        libnatpmp
        nftables
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

        update_qbittorrent() {
          port="$1"
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
            "$QUI_URL$proxy_path/api/v2/app/setPreferences" >/dev/null
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

          if ! update_qbittorrent "$udp_port"; then
            printf 'failed to update qBittorrent listening port to %s\n' "$udp_port" >&2
          fi

          nft delete table ip "$nft_table" 2>/dev/null || true
          nft -f - <<EOF
        table ip $nft_table {
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "$WIREGUARD_INTERFACE" tcp dport $udp_port dnat to $QBITTORRENT_IPV4:$udp_port
            iifname "$WIREGUARD_INTERFACE" udp dport $udp_port dnat to $QBITTORRENT_IPV4:$udp_port
          }
        }
        EOF

          sleep 45
        done
      '';
    };
  };
}
