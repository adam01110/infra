_: let
  inherit (builtins) listToAttrs;
in {
  # Build environment-variable attrs from a prefix and feature names.
  envFlags = prefix: names:
    listToAttrs (
      map (name: {
        name = "${prefix}_${name}";
        value = 1;
      })
      names
    );
}
