{self, ...}: {
  flake.modules.nixos.base = {
    imports = with self.modules.nixos; [
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
      users
      # keep-sorted end

      # Profiles
      stylixBase

      # Services
      # keep-sorted start
      ananicy
      avahi
      bpftune
      locate
      network
      nftables
      printing
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
      eh
      man
      sudo
      # keep-sorted end

      # TUI
      neovim
    ];
  };

  flake.modules.homeManager.base = {
    imports = with self.modules.homeManager; [
      # Profiles
      stylixBase

      # Desktop
      # keep-sorted start
      xdg
      xdgCleanup
      xdgDirs
      # keep-sorted end

      # CLI
      # keep-sorted start
      bat
      bun
      eh
      eza
      fastfetch
      fd
      nh
      nix-index
      npm
      nys
      ouch
      ripgrep
      speedtest
      starship
      tlrc
      # keep-sorted end

      # TUI
      # keep-sorted start block=yes
      atuin
      fzf
      neovim
      {
        key = "homeManager-btop";
        imports = [btop];
      }
      {
        key = "homeManager-yazi";
        imports = [yazi];
      }
      # keep-sorted end
    ];
  };
}
