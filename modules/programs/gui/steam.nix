{
  flake.modules.nixos.steam = {pkgs, ...}: {
    programs.steam = {
      enable = true;

      # Open necessary ports for remote play and on-LAN transfers.
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;

      protontricks.enable = true;

      # Include custom proton builds.
      extraCompatPackages = [pkgs.proton-ge-bin];

      fontPackages = [pkgs.noto-fonts-cjk-sans];
    };

    # Match the SteamOS defaults used on Steam Deck.
    boot.kernel.sysctl = {
      # keep-sorted start
      # last checked with https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamos-customizations-jupiter-20250117.1-1-any.pkg.tar.zst
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # Avoid split lock slowdown on supported kernels.
      "kernel.split_lock_mitigate" = 0;
      # Shorten fin timeout for games that restart quickly.
      "net.ipv4.tcp_fin_timeout" = 5;
      # Use MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      "vm.max_map_count" = 2147483642;
      # keep-sorted end
    };
  };
}
