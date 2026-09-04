{
  flake.modules.nixos.gnome-keyring = {
    # keep-sorted start block=yes newline_separated=yes
    security.pam.services = {
      # keep-sorted start
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
      # keep-sorted end
    };

    services.gnome = {
      # keep-sorted start newline_separated=yes
      # Disable the gcr SSH agent managed by GNOME.
      gcr-ssh-agent.enable = false;

      # Start keyring services for secret storage.
      gnome-keyring.enable = true;
      # keep-sorted end
    };
    # keep-sorted end
  };
}
