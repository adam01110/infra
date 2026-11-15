{
  flake.aspects.man.nixos = {pkgs, ...}: {
    documentation = {
      man.cache.enable = true;
      dev.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      man-pages
      man-pages-posix
      # keep-sorted end
    ];
  };
}
