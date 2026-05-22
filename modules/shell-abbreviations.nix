{
  flake.modules.homeManager.shellAbbreviations = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.home.shellAbbreviations;
  in {
    options.home.shellAbbreviations = mkOption {
      description = ''
        Shell abbreviations that expand as fish abbreviations and fall back to
        aliases in shells without native abbreviation support.
      '';

      type = types.attrsOf types.str;
      default = {};
    };

    config = {
      # keep-sorted start
      programs.bash.shellAliases = cfg;
      programs.fish.shellAbbrs = cfg;
      programs.nushell.shellAliases = cfg;
      programs.zsh.shellAliases = cfg;
      # keep-sorted end
    };
  };
}
