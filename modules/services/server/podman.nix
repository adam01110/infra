{
  flake.modules.nixos.podman = {
    # keep-sorted start
    config,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
    hostname = config.networking.hostName;
    secret = config.sops.placeholder;
  in {
    virtualisation = {
      podman = {
        enable = true;
        # Expose docker-compatible socket for tooling that expects dockerd.
        dockerSocket.enable = true;
      };

      # Disable the podman compose warning about external command execution.
      containers.containersConf.settings.engine.compose_warning_logs = false;
    };

    sops.templates."podman-dns.conf" = {
      mode = "0444";
      content = ''
        [containers]
        dns_servers = [
          "${secret."dns/${hostname}/dns_1"}",
          "${secret."dns/${hostname}/dns_2"}",
          "${secret."dns/${hostname}/dns_3"}",
          "${secret."dns/${hostname}/dns_4"}",
        ]
      '';
    };

    systemd.services.podman-dns-conf = {
      after = ["sops-install-secrets.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "podman-dns-conf" ''
          set -eu
          mkdir -p /etc/containers/containers.conf.d
          ${pkgs.gnused}/bin/sed 's/#.*"/"/' ${config.sops.templates."podman-dns.conf".path} > /etc/containers/containers.conf.d/00-dns.conf
        '';
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    environment.systemPackages = [pkgs.podman-compose];

    networking.firewall.extraInputRules = ''
      iifname "podman*" udp dport 53 accept
      iifname "podman*" tcp dport 53 accept
    '';

    users.users.${username}.extraGroups = ["podman"];
  };
}
