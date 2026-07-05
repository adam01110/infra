{
  flake.modules.homeManager.starship = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib.self)
      # keep-sorted start
      starshipBase01Segment
      starshipJujutsuPrompt
      # keep-sorted end
      ;
    inherit (lib) getExe;

    stylixColors = config.lib.stylix.colors.withHashtag;
    jjStarshipPrompt = starshipJujutsuPrompt pkgs stylixColors.base01;
  in {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      custom.jj =
        starshipBase01Segment "$output" "base0E bold"
        // {
          command = getExe jjStarshipPrompt;
          ignore_timeout = true;
          shell = [
            (getExe pkgs.fish)
            "-c"
          ];
          use_stdin = false;
          when = "${getExe pkgs.jj-starship} detect";
        };

      fossil_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "fg:base0E bold";
      };
      # keep-sorted end
    };
  };
}
