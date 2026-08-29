{
  flake.modules.homeManager.ghostty = {pkgs, ...}: let
    compactLibadwaita = pkgs.libadwaita.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [./patches/libadwaita-compact-tabs.patch];
    });
  in {
    programs.ghostty = {
      # keep-sorted start
      enable = true;
      package = pkgs.ghostty.override {libadwaita = compactLibadwaita;};
      # keep-sorted end
    };
  };
}
