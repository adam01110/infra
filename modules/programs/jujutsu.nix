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

    programs.jujutsu = {
      enable = true;

      settings = {
        aliases = {
          # keep-sorted start block=yes newline_separated=yes
          clone = {
            definition = ["git" "clone"];
            doc = "Clone a Git repository";
          };

          pull = {
            definition = ["util" "exec" "--" "sh" "-c" "jj git fetch && jj rebase -d 'trunk()'"];
            doc = "Fetch and rebase onto the remote trunk";
          };

          push = {
            definition = ["git" "push"];
            doc = "Push to a Git remote";
          };
          # keep-sorted end
        };

        signing = {
          backend = "gpg";
          behavior = "own";
          key = gitSigningKey;
        };

        ui.default-command = "log";
      };
    };
  };
}
