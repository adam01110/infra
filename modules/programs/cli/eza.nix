{
  flake.modules.homeManager.eza = _: {
    programs.eza = {
      enable = true;

      colors = "always";
      icons = "always";
      extraOptions = [
        # keep-sorted start
        "--all"
        "--group-directories-first"
        "--long"
        "--mounts"
        "--time-style=long-iso"
        # keep-sorted end
      ];
    };
  };
}
