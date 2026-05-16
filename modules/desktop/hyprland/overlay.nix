{inputs, ...}: {
  flake.overlays.hyprland = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    packages = inputs.hyprland.packages.${system};
  in {
    inherit
      (packages)
      # keep-sorted start
      hyprland
      xdg-desktop-portal-hyprland
      # keep-sorted end
      ;
  };
}
