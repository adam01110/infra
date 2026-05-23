_: let
  inherit (builtins) genList;

  mkDirection = key: direction: label: resize: {
    inherit
      # keep-sorted start
      direction
      key
      label
      resize
      # keep-sorted end
      ;
  };
in {
  hyprlandDirections = [
    # keep-sorted start block=yes newline_separated=yes
    (mkDirection "Down" "d" "down" {
      x = 0;
      y = 20;
    })

    (mkDirection "H" "l" "left" {
      x = -20;
      y = 0;
    })

    (mkDirection "J" "d" "down" {
      x = 0;
      y = 20;
    })

    (mkDirection "K" "u" "up" {
      x = 0;
      y = -20;
    })

    (mkDirection "L" "r" "right" {
      x = 20;
      y = 0;
    })

    (mkDirection "Left" "l" "left" {
      x = -20;
      y = 0;
    })

    (mkDirection "Right" "r" "right" {
      x = 20;
      y = 0;
    })

    (mkDirection "Up" "u" "up" {
      x = 0;
      y = -20;
    })
    # keep-sorted end
  ];

  # keep-sorted start
  hyprlandGroupNumbers = genList (index: index + 1) 5;
  hyprlandWorkspaceNumbers = genList (index: index + 1) 8;
  # keep-sorted end
}
