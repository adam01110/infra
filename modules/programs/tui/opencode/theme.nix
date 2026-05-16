{self, ...}: {
  flake.modules.homeManager.opencode = _: {
    imports = [self.modules.homeManager.stylixBase];

    # Keep the opencode background transparent to match stylix.
    stylix.targets.opencode = {
      enable = true;

      colors.override.withHashtag = {
        base00 = "none";
        base06 = "none";
      };
    };
  };
}
