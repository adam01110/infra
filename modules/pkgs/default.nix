{self, ...}: {
  flake.overlays.pkgs = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    packages = self.packages.${system};
  in {
    inherit
      (packages)
      # keep-sorted start
      djvutorga-adapter
      lutris
      os-age
      pptx2md-adapter
      systemd-status-preview
      zaread
      # keep-sorted end
      ;
  };
}
