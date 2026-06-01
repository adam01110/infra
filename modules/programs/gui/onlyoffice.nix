{
  flake.modules.homeManager.onlyoffice = {vars, ...}: let
    inherit (vars) fullName;
  in {
    programs.onlyoffice = {
      # keep-sorted start block=yes newline_separated=yes
      enable = true;

      # Set ui preferences.
      settings = {
        # keep-sorted start
        UITheme = "theme-dark";
        uiscaling = 100;
        usegpu = true;
        username = fullName;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
