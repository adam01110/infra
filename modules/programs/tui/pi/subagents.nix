{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    jsonFormat = pkgs.formats.json {};

    # subagents reads global defaults from ~/.pi/agent/subagents.json and never
    # writes there (the settings UI only writes the project file), so the
    # declarative baseline can stay writable like the MCP config.
    subagentsConfig = jsonFormat.generate "pi-subagents.json" {
      toolDescriptionMode = "compact";
    };
  in {
    home.activation.writePiSubagentsConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/install -Dm600 ${subagentsConfig} "$HOME/.pi/agent/subagents.json"
    '';
  };
}
