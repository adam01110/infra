{
  flake.aspects.optiscaler.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.optiscaler-client];
  };
}
