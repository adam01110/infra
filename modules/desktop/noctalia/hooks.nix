{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.noctalia-shell.settings.hooks = let
      performantMode = getExe pkgs.performant-mode;
    in {
      enabled = true;

      # keep-sorted start
      performanceModeDisabled = performantMode;
      performanceModeEnabled = performantMode;
      # keep-sorted end
    };
  };
}
