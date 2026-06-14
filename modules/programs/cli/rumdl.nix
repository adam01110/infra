{
  flake.modules.homeManager.rumdl = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    tomlFormat = pkgs.formats.toml {};
  in {
    xdg.configFile."rumdl/rumdl.toml".source = tomlFormat.generate "rumdl-config.toml" {
      global.cache_dir = "${config.xdg.cacheHome}/rumdl";
    };
  };
}
