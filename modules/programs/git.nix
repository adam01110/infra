{
  flake.modules.homeManager.git = {
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

      # Small include that injects the sops email into git config.
      templates."git-config".content = ''
        [user]
          email = ${config.sops.placeholder."git/email"}
      '';
    };

    # keep-sorted start block=yes newline_separated=yes
    # Publish the public key alongside the private key path.
    home.file.".ssh/git.pub".text = gitPublicSshkey;

    programs = {
      git = {
        enable = true;

        settings = {
          user = {
            name = fullName;
            signingkey = gitSigningKey;
          };

          init.defaultBranch = "main";

          # keep-sorted start
          commit.gpgsign = true;
          tag.gpgSign = true;
          # keep-sorted end

          # Store https credentials via the desktop keyring (libsecret).
          credential.helper = "${pkgs.git}/libexec/git-core/git-credential-libsecret";
        };

        # Include the sops-generated snippet to set the email.
        includes = [{inherit (config.sops.templates."git-config") path;}];
      };
    };
    # keep-sorted end
  };
}
