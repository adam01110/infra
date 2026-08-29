{self, ...}: {
  flake.modules.nixos.winboat = {pkgs, ...}: let
    podmanWinboat = pkgs.winboat.override {
      docker-compose = pkgs.podman-compose;
    };

    winboat = podmanWinboat.overrideAttrs (previousAttrs: {
      postPatch =
        (previousAttrs.postPatch or "")
        + ''
          substituteInPlace src/renderer/data/podman.ts \
            --replace-fail 'DISK_SIZE: "64G",' 'DISK_SIZE: "64G", DISK_IO: "io_uring",'
        '';
    });
  in {
    imports = [self.modules.nixos.virtualizationHost];

    boot.kernelModules = [
      # keep-sorted start
      "ip_tables"
      "iptable_nat"
      # keep-sorted end
    ];

    environment.systemPackages = [winboat];
  };
}
