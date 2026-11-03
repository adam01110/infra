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

    # Upstream git omits the libsecret helper unless it is built in.
    git = pkgs.git.override {withLibsecret = true;};
  in {
    sops = {
      secrets = {
        "git/college_forge/host" = {};

        # Per-user git email address stored in sops.
        "git/email" = {};

        # Place the decrypted private key at a stable path used by ssh.
        "git/private_ssh_key".path = "/home/${username}/.ssh/git";
      };

      # Keep private Git settings out of the Nix store.
      templates."git-config".content = ''
        [user]
          email = ${config.sops.placeholder."git/email"}
        [credential "https://${config.sops.placeholder."git/college_forge/host"}"]
          helper =
          helper = !glab auth git-credential
      '';
    };

    # keep-sorted start block=yes newline_separated=yes
    # Publish the public key alongside the private key path.
    home.file.".ssh/git.pub".text = gitPublicSshkey;

    programs = {
      git = {
        enable = true;
        package = git;

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

          # Store generic https credentials via the desktop keyring.
          credential.helper = "${git}/libexec/git-core/git-credential-libsecret";
        };

        # Include private settings after the default credential helper.
        includes = [{inherit (config.sops.templates."git-config") path;}];
      };
    };
    # keep-sorted end
  };
}
