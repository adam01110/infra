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
      bun =
        starshipBase01Segment "$symbol($version)" "yellow bold"
        // {
          symbol = " ";
        };

      deno =
        starshipBase01Segment "$symbol($version)" "green bold"
        // {
          symbol = " ";
        };

      nodejs =
        starshipBase01Segment "$symbol($version)" "green bold"
        // {
          symbol = "󰎙 ";
          not_capable_style = starshipBase01Style "base08 bold";
        };
      # keep-sorted end
    };
  };
}
