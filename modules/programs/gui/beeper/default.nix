{
  flake.aspects.beeper.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.forkprince.beeper-nightly];
  };
}
