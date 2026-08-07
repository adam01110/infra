{inputs, ...}: {
  flake.overlays.hyprland = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    packages = inputs.hyprland.packages.${system};
  in {
    inherit (packages) xdg-desktop-portal-hyprland;

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
