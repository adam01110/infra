{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    tomlFormat = pkgs.formats.toml {};
  in {
    xdg.configFile."rtk/config.toml".source = tomlFormat.generate "rtk-config.toml" {
      # keep-sorted start block=yes newline_separated=yes
      display.colors = false;

      filters.ignore_dirs = [
        # keep-sorted start
        ".direnv"
        ".git"
        ".rumdl_cache"
        ".venv"
        "__pycache__"
        "dist"
        "node_modules"
        "target"
        "vendor"
        # keep-sorted end
      ];

      telemetry.enabled = false;
      # keep-sorted end
    };
  };
}
