{self, ...}: {
  flake.modules.nixos.base = {
    imports =
      (with self.modules.generic; [
        # keep-sorted start
        determinate
        vars
        # keep-sorted end
      ])
      ++ (with self.modules.nixos; [
        # Core
        # keep-sorted start
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

        # CLI
        # keep-sorted start
        bandwhich
        man
        sudo
        # keep-sorted end

        # TUI
        neovim
      ]);
  };

  flake.modules.homeManager.base = {
    imports =
      [self.modules.generic.vars]
      ++ (with self.modules.homeManager; [
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
        nur
        shellAbbreviations
        sops
        # keep-sorted end

        # CLI
        # keep-sorted start
        bat
        bun
        eza
        fastfetch
        fd
        fish
        nh
        nix-index
        npm
        nys
        ouch
        ripgrep
        speedtest
        starship
        tlrc
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
        yazi
        # keep-sorted end
      ]);
  };
}
