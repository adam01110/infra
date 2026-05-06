{self, ...}: {
  flake.overlays.ripgrep-all-adapters = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;

    packages = self.packages.${system};
  in {
    inherit
      (packages)
      # keep-sorted start
      djvutorga-adapter
      pptx2md-adapter
      # keep-sorted end
      ;
  };
}
