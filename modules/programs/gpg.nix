{
  flake.modules.homeManager.gpg = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: {
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

      # Expose an ssh agent socket from gpg-agent so ssh can use
      # Keys stored on smartcards or in the gpg keyring.
      enableSshSupport = true;

      # Use the gnome pinentry for passphrase prompts.
      pinentry.package = pkgs.pinentry-gnome3;
    };

    systemd.user.services.set-SSH_AUTH_SOCK.Service.Environment = ["GNUPGHOME=${config.programs.gpg.homedir}"];
    # keep-sorted end
  };
}
