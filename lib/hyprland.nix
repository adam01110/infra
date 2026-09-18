_: let
  inherit
    (builtins)
    # keep-sorted start
    genList
    length
    # keep-sorted end
    ;

  # hyprsplit offsets each monitor by the workspace count, so names repeat.
  # keep-sorted start
  workspaceNames = ["I" "II" "III" "IV" "V" "VI" "VII" "VIII"];
  workspaceNamesAll = workspaceNames ++ workspaceNames;
  workspaceNumbers = genList (index: index + 1) 8;
  workspaceNumbersAll = genList (index: index + 1) (2 * length workspaceNames);
  # keep-sorted end

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
  hyprlandWorkspaceNames = workspaceNames;
  hyprlandWorkspaceNamesAll = workspaceNamesAll;
  hyprlandWorkspaceNumbers = workspaceNumbers;
  hyprlandWorkspaceNumbersAll = workspaceNumbersAll;
  # keep-sorted end
}
