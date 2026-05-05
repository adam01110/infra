{
  flake.modules.nixos.man = {pkgs, ...}: let
    inherit (builtins) attrValues;
  in {
    documentation = {
      man.cache.enable = true;
      dev.enable = true;
    };

    environment.systemPackages = attrValues {
      inherit
        (pkgs)
        # keep-sorted start
        man-pages
        man-pages-posix
        # keep-sorted end
        ;
    };
  };
}
