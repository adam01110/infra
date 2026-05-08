_: let
  inherit (builtins) listToAttrs;
in {
  # Build mime application entries for a desktop handler.
  mimeAppEntries = prefix: desktop: names:
    map (name: {
      name = "${prefix}/${name}";
      value = desktop;
    })
    names;

  # Convert mime application entries to an attrset.
  mimeAppDefaults = listToAttrs;
}
