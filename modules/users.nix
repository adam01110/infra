{
  flake.modules.nixos.users = {
    # keep-sorted start
    config,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (vars)
      # keep-sorted start
      fullName
      username
      # keep-sorted end
      ;
  in {
    # Ensure the user account can be created with a password managed by sops-nix.
    sops.secrets.user_password.neededForUsers = true;

    # Allow the user to perform privileged nix operations.
    nix.settings = {
      # keep-sorted start
      allowed-users = [username];
      trusted-users = [username];
      # keep-sorted end
    };

    users = {
      # Manage users declaratively, disables imperative changes via passwd/useradd.
      mutableUsers = false;

      users.${username} = {
        hashedPasswordFile = config.sops.secrets.user_password.path;

        extraGroups = [
          # keep-sorted start
          "audio"
          "render"
          "video"
          "wheel"
          # keep-sorted end
        ];

        isNormalUser = true;
        description = fullName;
        shell = pkgs.fish;

        # Allow non-standard shells without /etc/shells checks.
        ignoreShellProgramCheck = true;
      };
    };
  };
}
