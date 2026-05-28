{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs = {
    eh = {
      url = "github:NotAShelf/eh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.eh = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    inherit (pkgs) writeShellApplication;

    # keep-sorted start
    eh = getExe pkgs.eh;
    nix = getExe' pkgs.nix "nix";
    # keep-sorted end

    nixWrapper = writeShellApplication {
      name = "nix";
      text = ''
        case "''${1-}" in
          build|develop|run|shell)
            exec ${eh} "$@"
            ;;
          flake)
            if [[ $# -ge 2 && "''${2-}" == update ]]; then
              shift 2
              exec ${eh} update "$@"
            fi
            ;;
        esac

        exec ${nix} "$@"
      '';
    };
  in {
    home.packages = [pkgs.eh nixWrapper];
  };

  flake.modules.nixos.eh = {
    nixpkgs.overlays = [self.overlays.eh];
  };

  flake.overlays.eh = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
  in {
    inherit (inputs.eh.packages.${system}) eh;
  };
}
