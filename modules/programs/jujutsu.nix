{
  flake.modules.homeManager.jujutsu = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (vars)
      # keep-sorted start
      fullName
      gitPublicSshkey
      gitSigningKey
      username
      # keep-sorted end
      ;
  in {
    sops = {
      secrets = {
        # Per-user git email address stored in sops.
        "git/email" = {};

        # Place the decrypted private key at a stable path used by ssh.
        "git/private_ssh_key".path = "/home/${username}/.ssh/git";
      };

      templates."jj-user-config" = {
        content = ''
          [user]
          email = "${config.sops.placeholder."git/email"}"
          name = "${fullName}"
        '';
        path = "${config.xdg.configHome}/jj/conf.d/10-user.toml";
      };
    };

    # keep-sorted start block=yes newline_separated=yes
    # Publish the public key alongside the private key path.
    home.file.".ssh/git.pub".text = gitPublicSshkey;

    programs.jujutsu = {
      enable = true;

      settings = {
        signing = {
          backend = "gpg";
          behavior = "own";
          key = gitSigningKey;
        };

        ui.default-command = "log";
      };
    };
    # keep-sorted end
  };
}
