{
  flake.modules.homeManager.gpg = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeShellArg
      getExe
      # keep-sorted end
      ;
    inherit (lib.hm.dag) entryAfter;
    inherit (pkgs) writeShellApplication;

    gpgHomedir = config.programs.gpg.homedir;
    ownertrustSecret = config.sops.secrets."gpg/ownertrust".path;
    privateKeysSecret = config.sops.secrets."gpg/private_keys".path;

    importGpgSecrets = writeShellApplication {
      name = "import-gpg-secrets";
      runtimeInputs = [
        # keep-sorted start
        config.programs.gpg.package
        pkgs.coreutils
        # keep-sorted end
      ];
      text = ''
        gpgHomedir=${escapeShellArg gpgHomedir}
        ownertrustSecret=${escapeShellArg ownertrustSecret}
        privateKeysSecret=${escapeShellArg privateKeysSecret}

        mkdir -p "$gpgHomedir"
        chmod 700 "$gpgHomedir"

        if [[ -f "$privateKeysSecret" ]]; then
          GNUPGHOME="$gpgHomedir" gpg --batch --import "$privateKeysSecret"
        fi

        if [[ -f "$ownertrustSecret" ]]; then
          GNUPGHOME="$gpgHomedir" gpg --batch --import-ownertrust "$ownertrustSecret"
        fi
      '';
    };
  in {
    sops.secrets = {
      # keep-sorted start
      "gpg/ownertrust" = {};
      "gpg/private_keys" = {};
      # keep-sorted end
    };

    home.activation.importGpgSecrets = entryAfter ["sops-nix"] ''
      run ${getExe importGpgSecrets}
    '';

    # keep-sorted start block=yes newline_separated=yes
    # Supply gcr for the gnome pinentry integration.
    home.packages = [pkgs.gcr];

    programs.gpg = {
      enable = true;

      # Store the keyring under xdg data home instead of ~/.gnupg.
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      enable = true;

      # Expose an ssh agent socket for smartcard and gpg keyring keys.
      enableSshSupport = true;

      # Use the gnome pinentry for passphrase prompts.
      pinentry.package = pkgs.pinentry-gnome3;
    };

    systemd.user.services.set-SSH_AUTH_SOCK.Service.Environment = ["GNUPGHOME=${config.programs.gpg.homedir}"];
    # keep-sorted end
  };
}
