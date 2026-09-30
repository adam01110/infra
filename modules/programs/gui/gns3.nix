{
  flake.modules.nixos.gns3 = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    password = config.sops.secrets."educloud/password".path;
    profile = config.sops.secrets."educloud/openvpn_profile".path;
    username = config.sops.secrets."educloud/username".path;
  in {
    environment.systemPackages = [pkgs.gns3-gui];

    sops.secrets = {
      # keep-sorted start block=yes newline_separated=yes
      "educloud/openvpn_profile" = {
        # keep-sorted start
        path = "/run/secrets/educloud.ovpn";
        restartUnits = ["gns3-openvpn-profile.service"];
        # keep-sorted end
      };

      "educloud/password" = {restartUnits = ["gns3-openvpn-profile.service"];};

      "educloud/username" = {restartUnits = ["gns3-openvpn-profile.service"];};
      # keep-sorted end
    };

    systemd.services.gns3-openvpn-profile = {
      description = "Import the Educloud OpenVPN profile into NetworkManager";

      # keep-sorted start
      after = ["NetworkManager.service" "sops-install-secrets.service"];
      requires = ["NetworkManager.service" "sops-install-secrets.service"];
      wantedBy = ["multi-user.target"];
      # keep-sorted end

      path = [pkgs.networkmanager];

      serviceConfig = {
        # keep-sorted start
        StateDirectory = "gns3-openvpn-profile";
        Type = "oneshot";
        # keep-sorted end
      };

      script = ''
        set -eu
        if [ ! -s "${profile}" ]; then
          exit 0
        fi

        result="$(nmcli connection import type openvpn file "${profile}")"
        if [[ ! $result =~ \(([[:xdigit:]-]{36})\) ]]; then
          echo "Cannot identify imported Educloud VPN connection: $result" >&2
          exit 1
        fi
        uuid="''${BASH_REMATCH[1]}"
        nmcli connection modify uuid "$uuid" connection.id Educloud connection.autoconnect no
        if [ -s "${username}" ]; then
          nmcli connection modify uuid "$uuid" vpn.user-name "$(< "${username}")"
        fi
        if [ -s "${password}" ]; then
          nmcli connection modify uuid "$uuid" +vpn.data password-flags=0 vpn.secrets "password=$(< "${password}")"
        fi

        uuid_file="$STATE_DIRECTORY/uuid"
        if [ -f "$uuid_file" ]; then
          read -r old_uuid < "$uuid_file"
          nmcli connection delete uuid "$old_uuid" || true
        fi
        printf '%s\n' "$uuid" > "$uuid_file"
      '';
    };
  };
}
