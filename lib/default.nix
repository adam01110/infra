{lib}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    foldl'
    functionArgs
    # keep-sorted end
    ;

  helperArgs = {
    inherit lib;
  };

  helperFiles =
    lib.filesystem.listFilesRecursive ./.
    |> filter (path: baseNameOf path != "default.nix");

  importHelper = file: let
    helper = import file;
  in
    helper (lib.filterAttrs (name: _: builtins.hasAttr name (functionArgs helper)) helperArgs);
in
  foldl' (acc: attrs: acc // attrs) {} (map importHelper helperFiles)
