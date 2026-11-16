{
  flake.aspects.educloud.nixos = {
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
    sops.secrets = {
      # keep-sorted start block=yes newline_separated=yes
      "educloud/openvpn_profile" = {
        # keep-sorted start
        path = "/run/secrets/educloud.ovpn";
        restartUnits = ["educloud-openvpn-profile.service"];
        # keep-sorted end
      };

      "educloud/password" = {restartUnits = ["educloud-openvpn-profile.service"];};

      "educloud/username" = {restartUnits = ["educloud-openvpn-profile.service"];};
      # keep-sorted end
    };

    systemd.services.educloud-openvpn-profile = {
      description = "Import the Educloud OpenVPN profile into NetworkManager";

      # keep-sorted start
      after = ["NetworkManager.service" "sops-install-secrets.service"];
      requires = ["NetworkManager.service" "sops-install-secrets.service"];
      wantedBy = ["multi-user.target"];
      # keep-sorted end

      path = [pkgs.networkmanager];

      serviceConfig.Type = "oneshot";

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

        # Earlier imports share the name, so drop every other Educloud VPN.
        while IFS=: read -r old_uuid type name; do
          if [ "$type" = vpn ] && [ "$name" = Educloud ] && [ "$old_uuid" != "$uuid" ]; then
            nmcli connection delete uuid "$old_uuid"
          fi
        done < <(nmcli -g UUID,TYPE,NAME connection show)
      '';
    };
  };
}
