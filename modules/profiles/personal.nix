{self, ...}: {
  flake.aspects = {aspects, ...}: {
    personal = {
      includes = with aspects; [
        # Profiles
        # keep-sorted start
        base
        ncps
        stylix.provides.personal
        # keep-sorted end

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
        keyd
        noctalia
        overzicht
        tuigreet
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
        # keep-sorted start
        appimage
        gtk
        java
        # keep-sorted end

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
        gns3
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
        avahi
        flatpak
        geoclue
        gnome-keyring
        gvfs
        libinput
        pipewire
        power-profiles-daemon
        printing
        rclone
        ssh-stunnel
        upower
        vpn
        # keep-sorted end
      ];

      nixos = {config, ...}: {
        disko.devices = (self.diskoConfigurations.ext4 config.disko.selectedDisk).disko.devices;
      };
    };
  };
}
