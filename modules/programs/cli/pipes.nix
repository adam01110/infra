{
  flake.aspects.pipes.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    pipes = pkgs.pipes-rs;
  in {
    home = {
      packages = [pipes];
      shellAliases.pipes = "${getExe pipes} -p 4";
    };
  };
}
