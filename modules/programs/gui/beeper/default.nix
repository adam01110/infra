{
  flake.modules.homeManager.beeper = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.forkprince.beeper-nightly];
  };
}
