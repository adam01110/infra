{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.noctalia-shell = {
      # keep-sorted start block=yes newline_separated=yes
      # Keep launcher runtime tools in the wrapped shell package path.
      packageOverrides.extraPackages = [pkgs.wtype];

      settings.appLauncher = {
        # keep-sorted start
        autoPasteClipboard = true;
        customLaunchPrefix = getExe pkgs.runapp;
        customLaunchPrefixEnabled = true;
        density = "comfortable";
        enableClipboardHistory = true;
        enableSettingsSearch = false;
        overviewLayer = true;
        position = "center";
        showIconBackground = true;
        terminalCommand = getExe config.xdg.terminal-exec.package;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
