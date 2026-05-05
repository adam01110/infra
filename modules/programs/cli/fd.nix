{
  flake.modules.homeManager.fd = _: {
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
