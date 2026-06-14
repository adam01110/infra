{
  flake.modules.homeManager.tlrc = {pkgs, ...}: let
    tomlFormat = pkgs.formats.toml {};
  in {
    # keep-sorted start block=yes newline_separated=yes
    home.packages = [pkgs.tlrc];

    xdg.configFile."tlrc/config.toml".source = tomlFormat.generate "tlrc-config.toml" {
      cache.auto_update = false;

      output = {
        platform_title = true;

        show_hyphens = true;
        example_prefix = "◇ ";

        option_style = "both";
      };

      style = {
        title = {
          color = "magenta";
          underline = true;
        };

        description.color = "white";

        bullet = {
          color = "green";
          bold = true;
        };
      };
    };
    # keep-sorted end
  };
}
