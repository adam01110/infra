{
  flake.modules.homeManager.tuicr = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) writeShellApplication;

    tomlFormat = pkgs.formats.toml {};
    tuicr = getExe pkgs.tuicr;

    gitReview = writeShellApplication {
      name = "git-review";
      text = ''
        revision="''${1:-HEAD}"
        if (( $# > 0 )); then
          shift
        fi

        exec ${tuicr} --revisions "$revision" "$@"
      '';
    };

    jjReview = writeShellApplication {
      name = "jj-review";
      text = ''
        revision="''${1:-@}"
        if (( $# > 0 )); then
          shift
        fi

        exec ${tuicr} --revisions "$revision" "$@"
      '';
    };
  in {
    home.packages = [pkgs.tuicr];

    programs = {
      git.settings.alias.review = "!${getExe gitReview}";

      jujutsu.settings.aliases.review = {
        definition = ["util" "exec" "--" (getExe jjReview)];
        doc = "Review changes with tuicr";
      };
    };

    xdg.configFile."tuicr/config.toml".source = tomlFormat.generate "tuicr-config.toml" {
      # keep-sorted start
      no_update_check = true;
      theme = "stylix";
      # keep-sorted end

      # keep-sorted start
      relative_line_numbers = true;
      show_pr_checks = true;
      # keep-sorted end
    };
  };
}
