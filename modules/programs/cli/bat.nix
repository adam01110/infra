{
  flake.modules.homeManager.bat = {pkgs, ...}: {
    # Enable bat with manuals.
    programs.bat = {
      enable = true;

      extraPackages = [pkgs.bat-extras.batman];

      syntaxes.just = {
        src = pkgs.nur.repos.adam0.bat-syntax-just;
        file = "Just.sublime-syntax";
      };
    };
  };
}
