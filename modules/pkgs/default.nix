{self, ...}: {
  flake.overlays.pkgs = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    packages = self.packages.${system};
  in {
    inherit
      (packages)
      # keep-sorted start
      crowdsec-blocklist-gotify-proxy
      crowdsec-blocklist-import
      dashboard-gh-notify
      dashboard-vcs-status
      djvutorga-adapter
      gotify-optimize-images
      jj-conflict-nvim
      man-preview
      os-age
      performant-mode
      pptx2md-adapter
      proton-port-forward
      rclone-bisync-runner
      systemd-status-preview
      telescope-all-recent-nvim
      text-preview
      zaread
      # keep-sorted end
      ;
  };
}
