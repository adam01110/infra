{
  flake.modules.nixos.ssh = {
    # keep-sorted start
    config,
    lib,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    inherit (vars) username;
    hostname = config.networking.hostName;
  in {
    sops.secrets."servers/${hostname}/public_ssh_key" = {
      owner = username;
      mode = "0400";
    };

    services.openssh = {
      enable = true;

      authorizedKeysFiles = mkForce [config.sops.secrets."servers/${hostname}/public_ssh_key".path];

      settings = {
        # keep-sorted start
        AllowUsers = [username];
        PermitRootLogin = "no";
        # keep-sorted end

        # keep-sorted start
        ChallengeResponseAuthentication = "no";
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitEmptyPasswords = "no";
        PubkeyAuthentication = "yes";
        # keep-sorted end

        # keep-sorted start
        MaxAuthTries = 3;
        MaxSessions = 4;
        # keep-sorted end

        # keep-sorted start
        AllowAgentForwarding = "no";
        AllowStreamLocalForwarding = "no";
        AllowTcpForwarding = "no";
        GatewayPorts = "no";
        PermitTunnel = "no";
        X11Forwarding = false;
        # keep-sorted end

        # keep-sorted start
        IgnoreRhosts = "yes";
        UseDns = false;
        # keep-sorted end

        # keep-sorted start
        ClientAliveCountMax = 0;
        ClientAliveInterval = 300;
        # keep-sorted end

        # keep-sorted start
        Compression = "no";
        PrintMotd = false;
        TCPKeepAlive = "no";
        # keep-sorted end
      };
    };
  };
}
