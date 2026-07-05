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
    inherit
      (builtins.mapAttrs (_: starshipJjTrueColor) config.lib.stylix.colors.withHashtag)
      # keep-sorted start
      base01
      base08
      base0A
      base0B
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
          type = "Symbol";
          symbol = " ";
          color = base0E;
          bg_color = base01;
          bold = true;
        }

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
          type = "Commit";
          color = base0B;
          bg_color = base01;
          bold = true;

          change = {
            color = base0B;
            bg_color = base01;
            bold = true;
          };

          commit = {
            color = base0B;
            bg_color = base01;
            bold = true;
          };

          empty_text = "(no description set)";
          max_length = 24;
          previous_message_symbol = "⇣";
          show_previous_if_empty = false;
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
            text = "empty";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          hidden = {
            text = "hidden";
            color = base0A;
            bg_color = base01;
            bold = true;
          };

          immutable = {
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
  in {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      custom.jj = {
        command = "${getExe pkgs.starship-jj} --ignore-working-copy starship prompt --starship-config ${starshipJjConfig}";
        format = "[ ](#00000000)[ ](bg:base01)[$output]($style)[ ](bg:base01)";
        ignore_timeout = true;
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
