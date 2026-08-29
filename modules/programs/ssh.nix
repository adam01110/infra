{
  flake.modules.homeManager.ssh = {vars, ...}: let
    inherit (vars) groundDomain username;
  in {
    sops.secrets = {
      # keep-sorted start
      "servers/euclid/private_ssh_key".path = "/home/${username}/.ssh/euclid";
      "servers/euclid/public_ssh_key".path = "/home/${username}/.ssh/euclid.pub";
      # keep-sorted end
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

        "knot.${groundDomain}" = {
          HostName = "knot.${groundDomain}";
          IdentityFile = "~/.ssh/git";
          Port = 2223;
          User = "git";
        };

        "tangled.org" = {
          HostName = "tangled.org";
          IdentityFile = "~/.ssh/git";
        };

        euclid = {
          HostKeyAlias = "euclid.${groundDomain}";
          HostName = "127.0.0.1";
          IdentitiesOnly = true;
          IdentityFile = "~/.ssh/euclid";
          Port = 2201;
        };
      };
    };
  };
}
