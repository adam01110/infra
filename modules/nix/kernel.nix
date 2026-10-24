{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel?ref=release";

  flake = {
    overlays.nix-cachyos-kernel = inputs.nix-cachyos-kernel.overlays.pinned;

    modules.nixos.kernel = {
      # keep-sorted start
      lib,
      pkgs,
      # keep-sorted end
      ...
    }: {
      nixpkgs.overlays = [self.overlays.nix-cachyos-kernel];

      nix.settings = let
        cache = "https://cache.lantian.pub/lantian";
      in {
        substituters = [cache];
        trusted-substituters = [cache];
        trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
      };

      # Use cachyos kernel for performance optimizations.
      boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

      # Avoid checking missing DTB support on x86 kernels.
      hardware.deviceTree.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isAarch64;
    };
  };
}
