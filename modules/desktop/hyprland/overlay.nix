{inputs, ...}: {
  flake.overlays.hyprland = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;

    packages = inputs.hyprland.packages.${system};
  in {
    # Keep the nixpkgs xdg-desktop-portal-hyprland: the Hyprland flake builds it
    # against its own older Qt, which clashes with the system Qt style plugins
    # and segfaults hyprland-share-picker when a Qt theme is set.

    # TODO(upstream): Remove after updating past Hyprland 0.56.2.
    # Accept Glaze 8 as supported by upstream Hyprland.
    hyprland = packages.hyprland.overrideAttrs (oldAttrs: {
      postPatch =
        oldAttrs.postPatch
        + ''
          substituteInPlace CMakeLists.txt \
            --replace-fail "find_package(glaze 7...<8 QUIET)" "find_package(glaze QUIET)"
        '';
    });
  };
}
