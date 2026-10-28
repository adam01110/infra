{
  flake.modules.homeManager.ssh = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) groundDomain username;
  in {
    sops.secrets = {
      "git/credential_host" = {};
      "git/private_forge/private_ssh_key".path = "/home/${username}/.ssh/private-forge";
      "git/private_forge/public_ssh_key".path = "/home/${username}/.ssh/private-forge.pub";

      # keep-sorted start
      "servers/euclid/private_ssh_key".path = "/home/${username}/.ssh/euclid";
      "servers/euclid/public_ssh_key".path = "/home/${username}/.ssh/euclid.pub";
      # keep-sorted end
    };

    sops.templates."ssh-private-forge".content = ''
      Host ${config.sops.placeholder."git/credential_host"}
        IdentitiesOnly yes
        IdentityFile ~/.ssh/private-forge
        User git
    '';

    programs.ssh = {
      enable = true;

      # Keep the default config disabled to quiet the upstream warning.
      enableDefaultConfig = false;
      includes = [config.sops.templates."ssh-private-forge".path];

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
