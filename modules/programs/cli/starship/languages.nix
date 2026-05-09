{
  flake.modules.homeManager.starship = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      starshipBase01Segment
      starshipBase01Style
      # keep-sorted end
      ;
  in {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      c =
        starshipBase01Segment "$symbol($version(-$name))" "blue bold"
        // {
          symbol = " ";
        };

      cpp =
        starshipBase01Segment "$symbol($version(-$name))" "green bold"
        // {
          disabled = false;
          symbol = " ";
        };

      dart =
        starshipBase01Segment "$symbol($version)" "blue bold"
        // {
          symbol = " ";
        };

      dotnet =
        starshipBase01Segment "$symbol($version)( $tfm)" "blue bold"
        // {
          symbol = "󰪮 ";
        };

      golang =
        starshipBase01Segment "$symbol($version)" "cyan bold"
        // {
          symbol = " ";
          not_capable_style = starshipBase01Style "base08 bold";
        };

      haskell =
        starshipBase01Segment "$symbol($version)" "magenta bold"
        // {
          symbol = "󰲒 ";
        };

      haxe =
        starshipBase01Segment "$symbol($version)" "base08 bold"
        // {
          symbol = " ";
        };

      java =
        starshipBase01Segment "$symbol($version)" "base08 bold"
        // {
          symbol = "󰅶 ";
        };

      kotlin =
        starshipBase01Segment "$symbol($version)" "base09 bold"
        // {
          symbol = "󱈙 ";
        };

      lua =
        starshipBase01Segment "$symbol($version)" "blue bold"
        // {
          symbol = "󰢱 ";
        };

      perl =
        starshipBase01Segment "$symbol($version)" "base09 bold"
        // {
          symbol = " ";
        };

      php =
        starshipBase01Segment "$symbol($version)" "blue bold"
        // {
          symbol = " ";
        };

      python =
        starshipBase01Segment "$symbol$pyenv_prefix($version)( \\($virtualenv\\))" "yellow bold"
        // {
          symbol = "󰌠 ";

          # Show the pyenv name with an uv prefix.
          pyenv_version_name = true;
          pyenv_prefix = "uv";
        };

      ruby =
        starshipBase01Segment "$symbol($version)" "base08 bold"
        // {
          symbol = " ";
        };

      rust =
        starshipBase01Segment "$symbol($version)" "base09 bold"
        // {
          symbol = "󱘗 ";
        };

      swift =
        starshipBase01Segment "$symbol($version)" "base09 bold"
        // {
          symbol = "󰛥 ";
        };

      zig =
        starshipBase01Segment "$symbol($version)" "yellow bold"
        // {
          symbol = " ";
        };
      # keep-sorted end
    };
  };
}
