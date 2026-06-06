{self, ...}: {
  flake.modules.nixos.euclid = {...}: {
    imports = with self.modules.nixos; [
      # Profiles
      server

      # Services
      # keep-sorted start
      authentik
      crowdsec-server
      godns
      mysql
      postgres
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    networking.hostName = "euclid";

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    # extra data mounts.
    fileSystems = let
      # helper for btrfs mounts with shared options.
      mkBtrfsMount = device: subvol: {
        inherit device;
        fsType = "btrfs";
        options = [
          # keep-sorted start
          "compress=zstd"
          "defaults"
          "noatime"
          "subvol=${subvol}"
          # keep-sorted end
        ];
      };
    in {
      # keep-sorted start
      "/mnt/immich" = mkBtrfsMount "/dev/disk/by-uuid/2262a52f-3110-462e-815a-7717886b8cc7" "root";
      "/mnt/media" = mkBtrfsMount "/dev/disk/by-uuid/7bf5484e-67c1-4c67-a20f-cd47b1d6fb21" "root";
      # keep-sorted end
    };
  };
}
