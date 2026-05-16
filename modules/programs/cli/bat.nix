{self, ...}: {
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
    imports = [
      # keep-sorted start
      self.modules.homeManager.fish
      self.modules.homeManager.nur
      # keep-sorted end
    ];

    programs.bat = {
      enable = true;

      extraPackages = [pkgs.bat-extras.batman];

      syntaxes.just = {
        src = pkgs.nur.repos.adam0.bat-syntax-just;
        file = "Just.sublime-syntax";
      };
    };

    home.shellAliases.cat = bat;

    programs.fish.interactiveShellInitSnippets = [
      # Reuse bat's pager environment inside fish sessions.
      ''
        batman --export-env | source
      ''
    ];
  };
}
