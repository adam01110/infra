{
  flake.aspects.node-red.homeManager = {
    # keep-sorted start
    config,
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

      # Keep flows and installed nodes under xdg data instead of ~/.node-red.
      postBuild = ''
        wrapProgram $out/bin/node-red \
          --add-flags "--userDir ${config.xdg.dataHome}/node-red" \
          --prefix PATH : ${makeBinPath (with pkgs; [
          gcc
          nodejs
        ])}
      '';
    };
  in {
    home.packages = [node-red];
  };
}
