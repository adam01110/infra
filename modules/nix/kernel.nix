{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel?ref=release";

  flake.overlays.nix-cachyos-kernel = inputs.nix-cachyos-kernel.overlays.pinned;

  flake.modules.nixos.kernel = {pkgs, ...}: {
    nixpkgs.overlays = [self.overlays.nix-cachyos-kernel];

    nix.settings = let
      cache = "https://attic.xuyh0120.win/lantian";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    };

    # Use cachyos kernel for performance optimizations.
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
  };
}
