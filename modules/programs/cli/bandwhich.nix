{
  flake.modules.nixos.bandwhich = {
    # Show per-process bandwidth usage from the tui.
    programs.bandwhich.enable = true;
  };
}
