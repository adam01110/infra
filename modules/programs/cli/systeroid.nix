{
  flake.modules.homeManager.systeroid = {pkgs, ...}: let
    iniFormat = pkgs.formats.ini {};
  in {
    # keep-sorted start block=yes newline_separated=yes
    home.packages = [pkgs.systeroid];

    # Generate systeroid settings.
    xdg.configFile."systeroid/systeroid.conf".source = iniFormat.generate "systeroid.conf" {
      general.display_deprecated = true;
      cli.output_type = "tree";
    };
    # keep-sorted end
  };
}
