{
  flake.modules.homeManager.starship = {lib, ...}: let
    inherit (lib.self) starshipBase01Segment;
  in {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      container =
        starshipBase01Segment "$symbol \\[$name\\]" "blue bold"
        // {
          symbol = " ";
        };

      docker_context =
        starshipBase01Segment "$symbol$context" "blue bold"
        // {
          symbol = "󰡨 ";
        };
      # keep-sorted end
    };
  };
}
