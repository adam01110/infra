{
  flake.modules.homeManager.bat = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    bat = getExe config.programs.bat.package;
  in {
    programs.bat = {
      enable = true;

      extraPackages = [pkgs.bat-extras.batman];

      syntaxes.just = {
        src = pkgs.nur.repos.adam0.bat-syntax-just;
        file = "Just.sublime-syntax";
      };
    };

    home.shellAliases.cat = bat;

    # TODO: Fish init batman export.
  };
}
