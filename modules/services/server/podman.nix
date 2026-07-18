{
  flake.modules.nixos.podman = {
    # keep-sorted start
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';
    inherit (vars) username;
    resolvedAddress = "169.254.0.53";
  in {
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = false;
        dockerSocket.enable = true;
        dockerCompat = true;
      };

      # Disable the podman compose warning about external command execution.
      containers.containersConf.settings.engine.compose_warning_logs = false;
    };

    # Forward container queries through the host's resolved stub.
    environment.etc."containers/containers.conf.d/00-dns.conf".text = ''
      [containers]
      dns_servers = ["${resolvedAddress}"]
    '';

    environment.systemPackages = [pkgs.podman-compose];

    services.resolved.settings.Resolve.DNSStubListenerExtra = resolvedAddress;

    systemd.services = {
      podman-dns-address = {
        description = "Configure the container DNS listener address";
        before = ["systemd-resolved.service"];
        unitConfig.DefaultDependencies = false;

        serviceConfig = {
          ExecStart = "${getExe' pkgs.iproute2 "ip"} address replace ${resolvedAddress}/32 dev lo";
          RemainAfterExit = true;
          Type = "oneshot";
        };
      };

      systemd-resolved = {
        after = ["podman-dns-address.service"];
        requires = ["podman-dns-address.service"];
      };
    };

    networking.firewall.extraInputRules = ''
      iifname "podman*" udp dport 53 accept
      iifname "podman*" tcp dport 53 accept
    '';

    users.users.${username}.extraGroups = ["podman"];
  };
}
