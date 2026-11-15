{
  flake.aspects.appimage.nixos = {pkgs, ...}: {
    programs.appimage = {
      enable = true;
      binfmt = true;

      # Add extra dependencies for appimages.
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          pkgs.icu
        ];
      };
    };
  };
}
