{
  flake.modules.homeManager.onlyoffice = {vars, ...}: let
    inherit (vars) fullName;
  in {
    programs.onlyoffice = {
      # keep-sorted start block=yes newline_separated=yes
      enable = true;

      settings = {
        # keep-sorted start
        # OnlyOffice keeps the gtk dialog unless this flag is set.
        "--xdg-desktop-portal" = true;
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
