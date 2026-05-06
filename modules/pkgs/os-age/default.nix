{self, ...}: {
  flake.overlays.os-age = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;

    packages = self.packages.${system};
  in {
    inherit (packages) os-age;
  };
}
