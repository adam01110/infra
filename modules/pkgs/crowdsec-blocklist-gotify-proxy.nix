_: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.crowdsec-blocklist-gotify-proxy = writeShellApplication {
      name = "crowdsec-blocklist-gotify-proxy";
      excludeShellChecks = ["SC2001"];
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        curl
        gnused
        jq
        # keep-sorted end
      ];
      text = ''
                set -eu

                GOTIFY_URL="http://127.0.0.1:44407/message"
                GOTIFY_KEY=$(cat "$CREDENTIALS_DIRECTORY/gotify_api_key")

                read -r _ _ _

                content_length=0
                while IFS= read -r line; do
                  line=$(echo "$line" | tr -d '\r')
                  [ -z "$line" ] && break
                  case "$line" in
                    [Cc]ontent-[Ll]ength:*) content_length=$(echo "$line" | sed 's/.*: *//');;
                  esac
                done

                body=$(dd bs=1 count="$content_length" 2>/dev/null)

                new_ips=$(echo "$body" | jq -r '.new_ips // 0')
                sources_ok=$(echo "$body" | jq -r '.sources_ok // 0')
                sources_failed=$(echo "$body" | jq -r '.sources_failed // 0')
                duration=$(echo "$body" | jq -r '.duration_seconds // 0')

                title="CrowdSec Blocklist Import"
                message="$new_ips IPs imported
        $sources_ok sources ok, $sources_failed failed, $duration s"

                curl -s -X POST \
                  -H "Content-Type: application/json" \
                  -H "X-Gotify-Key: $GOTIFY_KEY" \
                  -d "$(echo '{}' | jq --arg t "$title" --arg m "$message" '{title: $t, message: $m, priority: 3}')" \
                  "$GOTIFY_URL" >/dev/null

                printf 'HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK'
      '';
    };
  };
}
