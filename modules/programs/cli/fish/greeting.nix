{
  flake.modules.homeManager.fish = {
    # keep-sorted start
    
    lib,
    pkgs, ...
    # keep-sorted end
  }: let
    inherit (lib) getExe;

    # keep-sorted start
    boxes = getExe pkgs.boxes;
    fortune = getExe pkgs.fortune;
    # keep-sorted end
  in {
    programs.fish.functions.fish_greeting = {
      description = "Greeting to show when starting a fish shell.";
      body = ''
        ${fortune} -s | ${boxes} -d ansi
      '';
    };
  };
}
