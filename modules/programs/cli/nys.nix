{
  flake.aspects.nys.homeManager = {
    programs.nix-your-shell = {
      enable = true;

      # Show build progress with nom.
      nix-output-monitor.enable = true;
    };
  };
}
