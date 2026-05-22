{self, ...}: {
  flake.modules.homeManager.ssh = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    imports = with self.modules; [
      # keep-sorted start
      generic.vars
      homeManager.sops
      # keep-sorted end
    ];

    sops = {
      secrets = {
        # Hostname for the euclid server host, stored in sops.
        "servers/euclid/hostname" = {};

        # Write the ssh public and private keys.
        "servers/euclid/private_ssh_key".path = "/home/${username}/.ssh/euclid";
        "servers/euclid/public_ssh_key".path = "/home/${username}/.ssh/euclid.pub";
      };

      # Template that expands to a host block included below.
      templates."ssh-config-server".content = ''
        Host server
          HostName ${config.sops.placeholder."servers/euclid/hostname"}
          IdentityFile ~/.ssh/server
      '';
    };

    programs.ssh = {
      enable = true;

      # Keep the default config disabled to quiet the upstream warning.
      enableDefaultConfig = false;

      # Dedicate a key for github traffic to keep identities separate.
      matchBlocks."github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/git";
      };

      # Pull in the sops-generated server host.
      includes = [config.sops.templates."ssh-config-server".path];
    };
  };
}
