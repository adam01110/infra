{
  flake.modules.nixos.node-red = {
    # keep-sorted start
    pkgs,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) makeBinPath;
    inherit
      (pkgs)
      symlinkJoin
      makeWrapper
      ;
  in {
    environment.systemPackages = symlinkJoin {
      name = "node-red";
      paths = [pkgs.node-red];

      nativeBuildInputs = [makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/node-red --prefix PATH : ${makeBinPath (with pkgs; [
          gcc
          nodejs
        ])}
      '';
    };
  };
}
