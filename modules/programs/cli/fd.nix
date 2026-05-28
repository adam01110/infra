{
  flake.modules.homeManager.fd = {
    programs.fd = {
      enable = true;

      hidden = true;
      extraOptions = [
        # keep-sorted start
        "--color"
        "always"
        # keep-sorted end
      ];
    };
  };
}
