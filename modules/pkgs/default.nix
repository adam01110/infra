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
      man-preview
      nocheatsheet-nvim
      os-age
      performant-mode
      pptx2md-adapter
      systemd-status-preview
      telescope-all-recent-nvim
      text-preview
      zaread
      # keep-sorted end
      ;
  };
}
