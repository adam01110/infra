{
  flake.modules.nixos.podman = {
    # keep-sorted start
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
        dockerSocket.enable = true;
        dockerCompat = true;
      };

      # Disable the podman compose warning about external command execution.
      containers.containersConf.settings.engine.compose_warning_logs = false;
    };

    # Forward container queries through the host's resolved stub.
    environment.etc."containers/containers.conf.d/00-dns.conf".text = ''
      [containers]
      dns_servers = ["127.0.0.53"]
    '';

    environment.systemPackages = [pkgs.podman-compose];

    networking.firewall.extraInputRules = ''
      iifname "podman*" udp dport 53 accept
      iifname "podman*" tcp dport 53 accept
    '';

    users.users.${username}.extraGroups = ["podman"];
  };
}
