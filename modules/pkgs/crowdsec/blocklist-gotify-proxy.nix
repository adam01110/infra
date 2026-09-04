{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.crowdsec-blocklist-gotify-proxy = writeShellApplication {
      name = "crowdsec-blocklist-gotify-proxy";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        curl
        jq
        # keep-sorted end
      ];
      text = ''
        set -eu

        gotify_url="http://127.0.0.1:44407/message"
        gotify_key=$(cat "$CREDENTIALS_DIRECTORY/gotify_api_key")

        read -r _ _ _

        content_length=0
        while IFS= read -r line; do
          line=$(printf '%s' "$line" | tr -d '\r')
          [ -z "$line" ] && break

          case "$line" in
            [Cc]ontent-[Ll]ength:*)
              content_length=''${line#*:}
              content_length=''${content_length## }
              ;;
          esac
        done

        body=$(dd bs=1 count="$content_length" status=none)

        new_ips=$(jq -r '.new_ips // 0' <<<"$body")
        sources_ok=$(jq -r '.sources_ok // 0' <<<"$body")
        sources_failed=$(jq -r '.sources_failed // 0' <<<"$body")
        duration=$(jq -r '.duration_seconds // 0' <<<"$body")

        title="CrowdSec Blocklist Import"
        printf -v message '%s IPs imported\n%s sources ok, %s failed, %s s' \
          "$new_ips" "$sources_ok" "$sources_failed" "$duration"

        payload=$(jq -n \
          --arg title "$title" \
          --arg message "$message" \
          '{title: $title, message: $message, priority: 3}')

        curl --fail --silent --show-error \
          --header "Content-Type: application/json" \
          --header "X-Gotify-Key: $gotify_key" \
          --data "$payload" \
          "$gotify_url" >/dev/null

        printf 'HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK'
      '';
    };
  };
}
