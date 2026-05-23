{
  # keep-sorted start
  lib,
  self,
  # keep-sorted end
  ...
}: {
  flake.modules.homeManager.git = {
    # keep-sorted start
    config,
    osConfig,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib.self) blendHex;
    inherit
      (vars)
      # keep-sorted start
      fullName
      gitPublicSshkey
      gitSigningKey
      username
      # keep-sorted end
      ;

    colors = osConfig.lib.stylix.colors.withHashtag;
  in {
    imports = with self.modules; [
      # keep-sorted start
      generic.vars
      homeManager.sops
      homeManager.ssh
      # keep-sorted end
    ];

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
      git = let
        # Use git full so the libsecret credential helper is available.
        gitPackage = pkgs.gitFull;
      in {
        enable = true;
        lfs.enable = true;

        package = gitPackage;

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
          credential.helper = "${gitPackage}/libexec/git-core/git-credential-libsecret";
        };

        # Include the sops-generated snippet to set the email.
        includes = [{inherit (config.sops.templates."git-config") path;}];
      };

      delta = {
        enable = true;
        enableGitIntegration = true;

        options = with colors; {
          true-color = "always";
          line-numbers = true;
          side-by-side = true;
          syntax-theme = "base16-stylix";

          # Let the desktop MIME handler open linked files.
          hyperlinks = true;
          hyperlinks-file-link-format = "file://{path}#{line}";

          # keep-sorted start
          blame-palette = "${base00} ${base01} ${base02}";
          file-style = "${base0D} bold";
          hunk-header-decoration-style = "${base0D} ul";
          hunk-header-file-style = "${base0D} ul bold";
          hunk-header-line-number-style = "${base0A} box bold";
          line-numbers-left-style = base0D;
          line-numbers-minus-style = base08;
          line-numbers-plus-style = base0B;
          line-numbers-right-style = base0D;
          line-numbers-zero-style = base03;
          merge-conflict-ours-diff-header-decoration-style = "${base0D} box";
          merge-conflict-ours-diff-header-style = "${base0A} bold";
          merge-conflict-theirs-diff-header-decoration-style = "${base0D} box";
          merge-conflict-theirs-diff-header-style = "${base0A} bold";
          minus-emph-style = "${base00} ${blendHex 34 base00 base08}";
          minus-style = "syntax ${blendHex 22 base00 base08}";
          plus-emph-style = "${base00} ${blendHex 34 base00 base0B}";
          plus-style = "syntax ${blendHex 22 base00 base0B}";
          whitespace-error-style = "${base00} bold";
          # keep-sorted end
        };
      };
    };
    # keep-sorted end
  };
}
