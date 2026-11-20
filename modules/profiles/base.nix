{self, ...}: {
  flake.aspects = {aspects, ...}: {
    base = {
      includes = with aspects; [
        # Core
        # keep-sorted start
        bootvine
        capabilities
        disko
        envfs
        firmware
        home-manager
        kernel
        lanzaboote
        nix
        nix-ld
        nur
        sops
        users
        # keep-sorted end

        # Services
        # keep-sorted start
        ananicy
        bpftune
        firewall
        locate
        network
        podman
        timesyncd
        tmp
        udisks2
        zram
        # keep-sorted end

        # Common
        # keep-sorted start
        locale
        slim
        timezone
        tweaks
        # keep-sorted end

        # Desktop
        # keep-sorted start
        xdg
        xdgCleanup
        xdgDirs
        # keep-sorted end

        # Programs
        # keep-sorted start
        delta
        git
        jujutsu
        shellAbbreviations
        # keep-sorted end

        # CLI
        # keep-sorted start
        bandwhich
        bat
        bun
        eza
        fastfetch
        fd
        fish
        man
        nh
        nix-index
        npm
        nys
        ouch
        ripgrep
        rom
        speedtest
        starship
        sudo
        tlrc
        vivid
        zoxide
        # keep-sorted end

        # TUI
        # keep-sorted start block=yes
        atuin
        btop
        fzf
        neovim
        nvtop
        television
        tuicr
        yazi
        # keep-sorted end
      ];

      nixos.imports = with self.modules.generic; [
        # keep-sorted start
        determinate
        vars
        # keep-sorted end
      ];

      homeManager.imports = [self.modules.generic.vars];
    };
  };
}
