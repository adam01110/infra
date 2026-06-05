{
  flake.modules.homeManager.ssh = {vars, ...}: let
    inherit (vars) groundDomain username;
  in {
    sops.secrets = {
      "servers/euclid/private_ssh_key".path = "/home/${username}/.ssh/euclid";
      "servers/euclid/public_ssh_key".path = "/home/${username}/.ssh/euclid.pub";
    };

    programs.ssh = {
      enable = true;

      # Keep the default config disabled to quiet the upstream warning.
      enableDefaultConfig = false;

      # Dedicate a key for github traffic to keep identities separate.
      settings = {
        "github.com" = {
          HostName = "github.com";
          IdentityFile = "~/.ssh/git";
        };

        euclid = {
          HostName = "euclid.${groundDomain}";
          IdentityFile = "~/.ssh/euclid";
        };
      };
    };
  };
}
