{self, ...}: {
  flake.modules.nixos.spindleMicrovm = {pkgs, ...}: {
    imports = [self.modules.nixos.virtualizationHost];

    boot.kernelModules = [
      # keep-sorted start
      "tun"
      "vhost_vsock"
      "vsock_loopback"
      # keep-sorted end
    ];

    # Makes host tools available for read-only bind mounting.
    environment.systemPackages = [
      # keep-sorted start
      pkgs.e2fsprogs
      pkgs.iproute2
      pkgs.nix
      pkgs.qemu
      pkgs.slirp4netns
      pkgs.util-linux
      # keep-sorted end
    ];
  };
}
