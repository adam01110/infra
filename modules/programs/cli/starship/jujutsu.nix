{
  flake.modules.homeManager.starship = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.self) starshipJjTrueColor;
    stylixColors = config.lib.stylix.colors.withHashtag;

    ansiColor = value: let
      color = starshipJjTrueColor value;
    in "${toString color.TrueColor.r};${toString color.TrueColor.g};${toString color.TrueColor.b}";

    changeUniqueStyle = "1;48;2;${ansiColor stylixColors.base01};38;2;${ansiColor stylixColors.base0E}";
    changeRestStyle = "1;48;2;${ansiColor stylixColors.base01};38;2;${ansiColor stylixColors.base04}";

    inherit
      (builtins.mapAttrs (_: starshipJjTrueColor) stylixColors)
      # keep-sorted start
      base01
      base08
      base0A
      base0E
      # keep-sorted end
      ;

    starshipJjConfig = (pkgs.formats.toml {}).generate "starship-jj.toml" {
      bookmarks = {
        exclude = [];
        search_depth = 100;
      };

      module_separator = " ";
      reset_color = false;

      module = [
        {
          type = "Bookmarks";
          separator = " ";
          color = base0E;
          bg_color = base01;
          bold = true;
          behind_symbol = "⇡";
          ignore_empty_commits = "None";
          max_bookmarks = 1;
          surround_with_quotes = false;
        }

        {
          type = "State";
          separator = " ";

          conflict = {
            text = "conflict";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          divergent = {
            text = "divergent";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          empty = {
            disabled = true;
            text = "empty";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          hidden = {
            disabled = true;
            text = "hidden";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          immutable = {
            disabled = true;
            text = "immutable";
            color = base0A;
            bg_color = base01;
            bold = true;
          };
        }

        {
          type = "Metrics";
          color = base08;
          bg_color = base01;
          bold = true;
          hide_if_empty = true;
          template = "[{changed} {added}{removed}]";

          changed_files = {
            color = base08;
            bg_color = base01;
            bold = true;
          };

          added_lines = {
            prefix = "+";
            color = base08;
            bg_color = base01;
            bold = true;
          };

          removed_lines = {
            prefix = "-";
            color = base08;
            bg_color = base01;
            bold = true;
          };
        }
      ];
    };

    starshipJjPrompt = pkgs.writeShellApplication {
      name = "starship-jj-prompt";
      runtimeInputs = [
        pkgs.jujutsu
        pkgs.starship-jj
      ];
      text = ''
        unique="$(jj log --ignore-working-copy --no-graph -r @ -T 'change_id.shortest()' 2>/dev/null)"
        display="$(jj log --ignore-working-copy --no-graph -r @ -T 'change_id.shortest(8)' 2>/dev/null)"
        rest="''${display#"$unique"}"

        printf '\033[${changeUniqueStyle}m%s' "$unique"
        printf '\033[${changeRestStyle}m%s ' "$rest"
        exec starship-jj --ignore-working-copy starship prompt --starship-config ${starshipJjConfig}
      '';
    };
  in {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      custom.jj = {
        command = getExe starshipJjPrompt;
        format = "[ ](#00000000)[ ](bg:base01)[$output]($style)[ ](bg:base01)";
        ignore_timeout = true;
        shell = [
          "${getExe pkgs.fish}"
          "-c"
        ];
        style = "bg:base01 fg:base0E bold";
        use_stdin = false;
        when = "${getExe pkgs.starship-jj} root --quiet";
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
