_: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs) mkShell;
  in {
    devShells.default = mkShell {
      packages = with pkgs; [
        # keep-sorted start
        sops
        tokei
        # keep-sorted end
      ];
    };
  };
}
