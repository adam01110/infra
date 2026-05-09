{
  flake.modules.homeManager.opencode = {lib, ...}: let
    inherit (lib) mkOption types;
    inherit (lib.self) envFlags;
  in {
    options.programs.opencode.env = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Environment variables set by the wrapped opencode launcher.";
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
