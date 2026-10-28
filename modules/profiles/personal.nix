{self, ...}: {
  flake.modules = {
    nixos.personal = {config, ...}: {
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
        keyd
        noctalia
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
        # keep-sorted start
        gns3
        seahorse
        # keep-sorted end

        # Services
        # keep-sorted start
        avahi
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
        vpn
        # keep-sorted end
      ];

      disko.devices = (self.diskoConfigurations.ext4 config.disko.selectedDisk).disko.devices;
    };

    homeManager.personal = {
      imports = with self.modules.homeManager; [
        # Profiles
        base

        # Common
        # keep-sorted start
        env
        face
        gh
        glab
        gpg
        ssh
        sshfs
        # keep-sorted end

        # Desktop
        # keep-sorted start block=yes
        ghostty
        hyprland
        noctalia
        overzicht
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
        codexbar
        cpond
        direnv
        eh
        gen-license
        gitfetch
        hyfetch
        node-red
        onefetch
        pipes
        ripgrep-all
        rocksky
        rumdl
        # keep-sorted end

        # TUI
        # keep-sorted start block=yes
        albedo
        cava
        opencubicplayer
        scope-tui
        surge
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
        deckcraft
        discord
        eduvpn
        flatseal
        gimp
        gotify-desktop
        gridcraft
        loupe
        proton
        seahorse
        showtime
        spotify
        tangled
        wordcraft
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
  };
}
