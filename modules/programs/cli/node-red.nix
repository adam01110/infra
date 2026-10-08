{
  flake.modules.homeManager.node-red = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) makeBinPath;
    inherit
      (pkgs)
      makeWrapper
      symlinkJoin
      ;

    node-red = symlinkJoin {
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
  in {
    home.packages = [node-red];
  };
}
