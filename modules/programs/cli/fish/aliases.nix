{
  flake.modules.homeManager.fish = {
    # keep-sorted start
    
    lib,
    pkgs, ...
    # keep-sorted end
  }: let
    inherit (lib) getExe';
  in {
    programs.fish.shellAliases = {
      wget = getExe' pkgs.curl "wcurl";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
      "......." = "cd ../../../../../..";
    };
  };
}
