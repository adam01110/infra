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
      nocheatsheet-nvim
      os-age
      pptx2md-adapter
      systemd-status-preview
      telescope-all-recent-nvim
      zaread
      # keep-sorted end
      ;
  };
}
