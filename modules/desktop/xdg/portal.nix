{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake.modules.homeManager.xdgPortal = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit ((import "${inputs.hyprland}/nix/lib.nix" lib)) toHyprlang;
  in {
    imports = [self.modules.homeManager.hyprland];

    xdg.configFile = {
      "xdg-desktop-portal-termfilechooser/config".text = let
        terminalCommand = getExe config.xdg.terminal-exec.package;
      in ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        env=TERMCMD=${terminalCommand} --title=Termfilechooser
      '';

      "hypr/xdph.conf".text = toHyprlang {} {
        max_fps = 60;
      };
    };
  };

  flake.modules.nixos.xdgPortal = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkAfter;
  in {
    # keep-sorted start block=yes newline_separated=yes
    systemd.user.services.xdg-desktop-portal = {
      after = mkAfter ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];

      # Keep the portal on the session PATH imported into the user manager.
      enableDefaultPath = false;
    };

    xdg = {
      portal = {
        enable = true;

        # Route `xdg-open` calls through the portal.
        xdgOpenUsePortal = true;

        # keep-sorted start block=yes newline_separated=yes
        config = {
          # Defaults used by any desktop.
          common = {
            default = ["gtk"];

            # keep-sorted start

            # Use termfilechooser for file picking.
            "org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
            # Use gnome-keyring for the secret portal backend.
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
            # keep-sorted end
          };

          # Desktop-specific overrides for hyprland.
          hyprland = {
            default = [
              # keep-sorted start
              "gtk"
              "hyprland"
              # keep-sorted end
            ];

            # keep-sorted start

            # Use termfilechooser for file picking.
            "org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
            # Use gnome-keyring for the secret portal backend.
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
            # keep-sorted end
          };
        };

        # Provide the gtk and terminal file chooser portals.
        extraPortals = with pkgs; [
          # keep-sorted start
          xdg-desktop-portal-gtk
          xdg-desktop-portal-termfilechooser
          # keep-sorted end
        ];
        # keep-sorted end
      };
    };
    # keep-sorted end
  };
}
