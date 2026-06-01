{self, ...}: {
  flake.modules.nixos.personal = {config, ...}: {
    imports = with self.modules;
      [generic.determinate]
      ++ (with nixos; [
        # Profiles
        # keep-sorted start
        base
        stylixPersonal
        # keep-sorted end

        # Desktop
        # keep-sorted start block=yes
        hyprland
        noctalia
        polkit
        tablet
        tuigreet
        xdgPortal
        {
          key = "nixos-uwsm";
          imports = [uwsm];
        }
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
        evolution-data-server
        flatpak
        geoclue
        gnome-keyring
        gvfs
        libinput
        pipewire
        power-profiles-daemon
        upower
        # keep-sorted end
      ]);

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
      polkit
      stylixPersonal
      uwsm
      xdgApplications
      xdgPortal
      xdgTerminal
      {
        key = "homeManager-hyprland";
        imports = [hyprland];
      }
      {
        key = "homeManager-noctalia";
        imports = [noctalia];
      }
      {
        key = "homeManager-overzicht";
        imports = [overzicht];
      }
      # keep-sorted end

      # Programs
      gtk

      # CLI
      # keep-sorted start block=yes
      bonsai
      cpond
      direnv
      gitfetch
      onefetch
      pipes
      ripgrep-all
      rumdl
      {
        key = "homeManager-fish";
        imports = [fish];
      }
      {
        key = "homeManager-zoxide";
        imports = [zoxide];
      }
      # keep-sorted end

      # TUI
      # keep-sorted start block=yes
      cava
      opencode
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
      flatseal
      ghostty
      gimp
      loupe
      onlyoffice
      proton
      seahorse
      showtime
      spotify
      upscayl
      zaread
      zathura
      {
        key = "homeManager-discord";
        imports = [discord];
      }
      {
        key = "homeManager-zen";
        imports = [zen];
      }
      # keep-sorted end

      # Services
      flatpak
    ];
  };
}
