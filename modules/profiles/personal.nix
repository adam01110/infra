{self, ...}: {
  flake.modules.nixos.personal = {config, ...}: {
    imports = with self.modules.nixos; [
      # Profiles
      # keep-sorted start
      base
      ncps
      stylixPersonal
      # keep-sorted end

      # Desktop
      # keep-sorted start block=yes
      hyprland
      noctalia
      polkit
      tablet
      tuigreet
      uwsm
      xdgPortal
      # keep-sorted end

      # Programs
      # keep-sorted start
      appimage
      java
      # keep-sorted end

      # GUI
      seahorse

      # Services
      # keep-sorted start
      avahi
      evolution-data-server
      flatpak
      geoclue
      gnome-keyring
      gvfs
      libinput
      pipewire
      power-profiles-daemon
      printing
      ssh-stunnel
      upower
      # keep-sorted end
    ];

    disko.devices = (self.diskoConfigurations.ext4 config.disko.selectedDisk).disko.devices;
  };

  flake.modules.homeManager.personal = {
    imports = with self.modules.homeManager; [
      # Profiles
      base

      # Common
      # keep-sorted start
      env
      face
      gh
      gpg
      ssh
      sshfs
      # keep-sorted end

      # Desktop
      # keep-sorted start block=yes
      cliphist
      ghostty
      hyprland
      noctalia
      overzicht
      polkit
      stylixPersonal
      uwsm
      xdgApplications
      xdgPortal
      xdgTerminal
      # keep-sorted end

      # Hyprland plugins
      # keep-sorted start
      hyprlandHyprfocusPlugin
      hyprlandHyprsplitPlugin
      # keep-sorted end

      # Programs
      gtk

      # CLI
      # keep-sorted start block=yes
      bonsai
      cpond
      diffnav
      direnv
      gen-license
      gitfetch
      onefetch
      pi
      pipes
      ripgrep-all
      rumdl
      # keep-sorted end

      # TUI
      # keep-sorted start block=yes
      cava
      wiremix
      # keep-sorted end

      # GUI
      # keep-sorted start block=yes
      aseprite
      beeper
      bitwarden
      bleachbit
      crosspipe
      decibels
      discord
      flatseal
      gimp
      gotify-desktop
      loupe
      onlyoffice
      proton
      seahorse
      showtime
      spotify
      tangled
      zaread
      zathura
      zen
      # keep-sorted end

      # Services
      # keep-sorted start
      flatpak
      rclone
      # keep-sorted end
    ];
  };
}
