{
  flake.modules.homeManager.opencode = {lib, ...}: let
    inherit
      (lib)
      # keep-sorted start
      mkOption
      types
      # keep-sorted end
      ;
    inherit (lib.self) envFlags;
  in {
    options.programs.opencode.env = mkOption {
      description = "Environment variables set by the wrapped opencode launcher.";

      type = types.attrsOf types.anything;
      default = {};
    };

    config.programs.opencode.env = let
      experimentalFeatures = [
        # keep-sorted start
        "FILEWATCHER"
        "ICON_DISCOVERY"
        "LSP_TOOL"
        "LSP_TY"
        # keep-sorted end
      ];

      # Keep builtin lsp downloads disabled and rely on nix instead.
      disabledFeatures = [
        # keep-sorted start
        "AUTOCOMPACT"
        "LSP_DOWNLOAD"
        # keep-sorted end
      ];
      enabledFeatures = ["EXA"];
    in
      envFlags "OPENCODE_EXPERIMENTAL" experimentalFeatures
      // envFlags "OPENCODE_DISABLE" disabledFeatures
      // envFlags "OPENCODE_ENABLE" enabledFeatures;
  };
}
