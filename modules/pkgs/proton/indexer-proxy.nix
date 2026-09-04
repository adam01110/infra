{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.proton-indexer-proxy = writeShellApplication {
      name = "proton-indexer-proxy";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        tinyproxy
        # keep-sorted end
      ];
      text = ''
        set -eu

        config_file="$RUNTIME_DIRECTORY/tinyproxy.conf"
        password_file="$CREDENTIALS_DIRECTORY/proxy_password"
        user_file="$CREDENTIALS_DIRECTORY/proxy_user"

        cat > "$config_file" <<EOF
        Port 8888
        Listen $PROXY_LISTEN_ADDRESS
        Bind $PROXY_LISTEN_ADDRESS
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

        exec tinyproxy -d -c "$config_file"
      '';
    };
  };
}
